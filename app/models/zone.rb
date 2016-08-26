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

  # These control the spacing allocated to each column which is exported into
  # zone files.
  ZF_NAME_SPACE = 25
  ZF_TTL_SPACE = 8
  ZF_CLASS_SPACE = 4
  ZF_TYPE_SPACE = 10

  has_many :records, :dependent => :destroy

  validates :name, :presence => true, :hostname => true
  validates :primary_ns, :presence => true, :hostname => true
  validates :email_address, :presence => true, :email_address => true
  validates :serial, :numericality => {:only_integer => true, :allow_blank => true}
  validates :refresh_time, :numericality => {:only_integer => true}
  validates :retry_time, :numericality => {:only_integer => true}
  validates :expiration_time, :numericality => {:only_integer => true}
  validates :max_cache, :numericality => {:only_integer => true}
  validates :ttl, :numericality => {:only_integer => true}

  scope :stale, -> { where("published_at IS NULL OR updated_at > published_at") }

  default_value :refresh_time, -> { 3600 }
  default_value :retry_time, -> { 120 }
  default_value :expiration_time, -> { 2419200 }
  default_value :max_cache, -> { 600 }
  default_value :ttl, -> { 3600 }

  def zone_file_header
    String.new.tap do |s|
      s << "# Zone file exported from Bound at #{Time.now.utc.to_s}\n"
      s << "# Bound Zone ID: #{id}\n\n"
      s << "$TTL".ljust(ZF_NAME_SPACE, ' ') + " #{self.ttl}\n"
      s << "$ORIGIN".ljust(ZF_NAME_SPACE, ' ') + " #{self.name}\n\n"
      s << "@".ljust(ZF_NAME_SPACE, ' ') + " "
      s << "IN".ljust(ZF_CLASS_SPACE, ' ')
      s << "SOA".ljust(ZF_TYPE_SPACE, ' ') + " "
      s << format_hostname(self.primary_ns) + " "
      s << format_email(self.email_address) + " "
      s << "("
      s << (self.serial || (0)).to_s + " "
      s << self.refresh_time.to_s + " "
      s << self.retry_time.to_s + " "
      s << self.expiration_time.to_s + " "
      s << self.max_cache.to_s
      s << ")"
    end
  end

  def zone_file
    String.new.tap do |s|
      s << zone_file_header
      s << "\n\n"
      s << records.order(:name).map(&:bind_line).join("\n")
    end
  end

  def format_hostname(hostname)
    if hostname.ends_with?('.')
      hostname
    else
      "#{hostname}.#{name}"
    end
  end

  def format_email(email_address)
    email_address.to_s.gsub('@', '.') + "."
  end

  def mark_as_published
    update_column(:published_at, Time.now)
  end

  def self.publish(options = {})
    zones = options[:all] ? Zone.all : Zone.stale
    zone_directory = File.expand_path(Bound.config.bind.zone_export_path, Rails.root)
    puts "Exporting zones to #{zone_directory}".yellow
    FileUtils.mkdir_p(zone_directory)

    if zones.empty?
      puts "No zones were found to export".blue
      return false
    end

    zones.each do |zone|
      zone_file_path = File.join(zone_directory, zone.name + ".zone")
      File.open(zone_file_path, 'w') do |f|
        f.write(zone.zone_file + "\n")
      end
      zone.mark_as_published
      puts "=> Exported #{zone.name}".green
    end

    check_configuration
    reload_configuration
    zones
  end

  class BindError < StandardError
    attr_reader :error, :type

    def initialize(type, error)
      @type = type
      @error = error
    end

    def to_s
      "[#{@type}] #{@error}"
    end
  end

  def self.check_configuration
    if cmd = Bound.config.bind&.commands&.check_config
      stdout, stderr, status = Open3.capture3(cmd)
      if status == 0
        true
      else
        raise BindError.new(:config_error, stdout + stderr)
      end
    else
      Rails.logger.warn "Cannot check configuration before not check config command has been provided.".yellow
      true
    end
  end

  def self.reload_configuration
    if cmd = Bound.config.bind&.commands&.reload
      stdout, stderr, status = Open3.capture3(cmd)
      if status == 0
        true
      else
        raise BindError.new(:reload_error, stdout + stderr)
      end
    else
      Rails.logger.warn "Cannot reload configuration before not check config command has been provided.".yellow
      true
    end
  end

end
