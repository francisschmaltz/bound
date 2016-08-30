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

  # These control the spacing allocated to each column which is exported into
  # zone files.
  ZF_NAME_SPACE = 25
  ZF_TTL_SPACE = 8
  ZF_CLASS_SPACE = 4
  ZF_TYPE_SPACE = 10

  # Default values for new zones
  DEFAULT_REFRESH_TIME = 3600
  DEFAULT_RETRY_TIME = 120
  DEFAULT_EXPIRATION_TIME = 2419200
  DEFAULT_MAX_CACHE = 600
  DEFAULT_TTL = 3600

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

  default_value :primary_ns, -> { Bound.config.dns_defaults.primary_ns }
  default_value :email_address, -> { Bound.config.dns_defaults.email_address }
  default_value :serial, -> { 1 }
  default_value :refresh_time, -> { DEFAULT_REFRESH_TIME }
  default_value :retry_time, -> { DEFAULT_RETRY_TIME }
  default_value :expiration_time, -> { DEFAULT_EXPIRATION_TIME }
  default_value :max_cache, -> { DEFAULT_MAX_CACHE }
  default_value :ttl, -> { DEFAULT_TTL }

  ATTRIBUTES_TO_TRACK = ['primary_ns', 'email_address', 'refresh_time', 'retry_time', 'expiration_time', 'max_cache', 'ttl']

  after_create { Change.create!(:zone => self, :event => "ZoneAdded", :name => self.name) }
  after_destroy { Change.create!(:zone => self, :event => "ZoneDeleted", :name => self.name) }
  after_update do
    for key, (old_value, new_value) in self.changes
      next unless ATTRIBUTES_TO_TRACK.include?(key.to_s)
      Change.create!(:zone => self, :event => "ZoneAttributeChanged", :name => self.name, :attribute_name => key, :old_value => old_value, :new_value => new_value)
    end
  end

  def changes_pending?
    pending_changes.size > 0
  end

  def generate_zone_file_header
    String.new.tap do |s|
      s << "# Zone file exported from Bound at #{Time.now.utc.to_s}\n"
      s << "# Bound Zone ID: #{id}\n\n"
      s << "$TTL".ljust(ZF_NAME_SPACE, ' ') + " #{self.ttl}\n"
      s << "$ORIGIN".ljust(ZF_NAME_SPACE, ' ') + " #{self.name}\n\n"
      s << "@".ljust(ZF_NAME_SPACE, ' ') + " "
      s << "IN".ljust(ZF_CLASS_SPACE, ' ')
      s << "SOA".ljust(ZF_TYPE_SPACE, ' ') + " "
      s << self.primary_ns + " "
      s << self.email_address.to_s.gsub('@', '.') + " "
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

end
