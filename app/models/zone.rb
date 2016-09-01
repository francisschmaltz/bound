# == Schema Information
#
# Table name: zones
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  primary_ns      :string(255)
#  email_address   :string(255)
#  serial          :integer
#  refresh_time    :integer
#  retry_time      :integer
#  expiration_time :integer
#  max_cache       :integer
#  ttl             :integer
#  published_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'open3'

class Zone < ApplicationRecord

  attr_readonly :name

  ZF_NAME_SPACE = 25
  ZF_TTL_SPACE = 8
  ZF_CLASS_SPACE = 4
  ZF_TYPE_SPACE = 10

  has_many :records, :dependent => :destroy
  has_many :pending_changes, -> { pending }, :class_name => 'Change', :dependent => :destroy

  validates :name, :presence => true, :hostname => true, :uniqueness => true
  validates :primary_ns, :presence => true, :hostname => true
  validates :email_address, :presence => true, :email_address => true
  validates :serial, :numericality => {:only_integer => true, :allow_blank => true}
  validates :refresh_time, :numericality => {:only_integer => true}
  validates :retry_time, :numericality => {:only_integer => true}
  validates :expiration_time, :numericality => {:only_integer => true}
  validates :max_cache, :numericality => {:only_integer => true}
  validates :ttl, :numericality => {:only_integer => true}
  validate :validate_reverse_zone_name

  default_value :serial, -> { 1 }
  default_value :primary_ns, -> { Bound.config.dns_defaults.primary_ns }
  default_value :email_address, -> { Bound.config.dns_defaults.email_address }
  default_value :refresh_time, -> { Bound.config.dns_defaults.refresh_time }
  default_value :retry_time, -> { Bound.config.dns_defaults.retry_time }
  default_value :expiration_time, -> { Bound.config.dns_defaults.expiration_time }
  default_value :max_cache, -> { Bound.config.dns_defaults.max_cache }
  default_value :ttl, -> { Bound.config.dns_defaults.ttl }

  after_create :add_default_name_servers

  ATTRIBUTES_TO_TRACK = ['primary_ns', 'email_address', 'refresh_time', 'retry_time', 'expiration_time', 'max_cache', 'ttl']
  after_create { Change.create!(:zone => self, :event => "ZoneAdded", :name => self.name) }
  after_destroy { Change.create!(:zone => self, :event => "ZoneDeleted", :name => self.name) }
  after_update do
    for key, (old_value, new_value) in self.changes
      next unless ATTRIBUTES_TO_TRACK.include?(key.to_s)
      Change.create!(:zone => self, :event => "ZoneAttributeChanged", :name => self.name, :attribute_name => key, :old_value => old_value, :new_value => new_value)
    end
  end

  def description
    reverse? ? reverse_subnet.to_s : name
  end

  def ordered_records
    reverse_version == 4 ? records.order("CAST(name as SIGNED INTEGER), type, data") : records.order(:name, :type, :data)
  end

  def reverse_version
    @reverse_version ||= begin
      if name =~ /(in\-addr|ip6)\.arpa\z/
        $1 == "ip6" ? 6: 4
      else
        0
      end
    end
  end

  def reverse?
    reverse_version > 0
  end

  def reverse_subnet
    return nil unless reverse?
    @reverse_subnet ||= begin
      address = self.name.gsub(/\.(in\-addr|ip6)\.arpa\z/, '')
      if reverse_version == 4
        IPAddr.new(address.split('.').map(&:to_i).reverse.join(".") + ".0")
      else
        IPAddr.new(address.split('.').reverse.join.gsub(/(.{4})/, '\1:') + ":")
      end
    end
  end

  def validate_reverse_zone_name
    if self.name.present? && reverse?
      subnet = self.reverse_subnet rescue nil
      if subnet.nil?
        errors.add :name, "is not a valid reverse zone name"
      end
    end
  end

  def changes_pending?
    pending_changes.size > 0
  end

  def generate_zone_file_header
    String.new.tap do |s|
      s << "; Zone file exported from Bound at #{Time.now.utc.to_s}\n"
      s << "; Bound Zone ID: #{id}\n\n"
      s << "$TTL".ljust(ZF_NAME_SPACE, ' ') + " #{self.ttl}\n"
      s << "$ORIGIN".ljust(ZF_NAME_SPACE, ' ') + " #{self.name}.\n\n"
      s << "@".ljust(ZF_NAME_SPACE, ' ') + " "
      s << "IN".ljust(ZF_CLASS_SPACE, ' ')
      s << "SOA".ljust(ZF_TYPE_SPACE, ' ') + " "
      s << self.primary_ns + ". "
      s << self.email_address.to_s.gsub('@', '.') + ". "
      s << "("
      s << self.serial.to_s + " "
      s << self.refresh_time.to_s + " "
      s << self.retry_time.to_s + " "
      s << self.expiration_time.to_s + " "
      s << self.max_cache.to_s
      s << ")"
    end
  end

  def generate_zone_file
    String.new.tap do |s|
      s << generate_zone_file_header
      s << "\n\n"
      s << records.order(:name).map(&:bind_line).join("\n")
    end
  end

  def generate_zone_clause
    String.new.tap do |s|
      s << "zone \"#{name}\" {\n"
      s << "  type master;\n"
      s << "  file \"#{zone_file_path}\";\n"
      if notify = Bound.config.replication&.notify&.master
        s << "  notify #{notify};\n"
      end
      s << "};"
    end
  end

  def generate_zone_clause_for_slave
    return false unless Bound.config.replication
    String.new.tap do |s|
      s << "zone \"#{name}\" {\n"
      s << "  type slave;\n"
      s << "  file \"/var/lib/bind/#{name}\";\n"
      if notify = Bound.config.replication&.notify&.slave
        s << "  notify #{notify};\n"
      end
      s << "  masters {\n"
      for master in Bound.config.replication.masters
        s << "    #{master};\n"
      end
      s << "  };\n"
      s << "};"
    end
  end

  def mark_as_published(time = Time.now)
    self.pending_changes.update_all(:published_at => time, :serial => self.serial)
    update_columns(:published_at => time, :serial => self.serial + 1)
  end

  def zone_file_path
    @zone_file_path ||= File.join(Bound::Publisher.zone_directory, "#{name}.zone")
  end

  def add_default_name_servers
    if Bound.config.dns_defaults.nameservers.is_a?(Array)
      Bound.config.dns_defaults.nameservers.each do |ns|
        ns = ns.to_s + "." unless ns.ends_with?('.')
        self.records.create!(:type => Bound::BuiltinRecordTypes::NS.to_s, :form_data => {'name' => ns})
      end
    end
  end

  def zone_file_errors
    if cmd = Bound.config.bind.commands.check_zone_file
      temp_file = Tempfile.new
      File.open(temp_file.path, 'w') { |f| f.write(generate_zone_file + "\n") }
      command = "#{cmd} #{name} #{temp_file.path}"
      stdout, stderr, status = Open3.capture3(command)
      if status == 0
        nil
      else
        (stdout.to_s.strip + stderr.to_s.strip).gsub(temp_file.path, "#{self.name}.zone")
      end
    else
      nil
    end
  end

end
