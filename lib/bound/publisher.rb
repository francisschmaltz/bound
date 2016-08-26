module Bound
  class Publisher

    def self.zone_directory
      @zone_directory ||= File.expand_path(Bound.config.bind.zone_export_path, Rails.root)
    end

    def self.zone_clauses_file
      @zone_clauses_file ||= File.expand_path(Bound.config.bind.zone_clauses_file, Rails.root)
    end

    def initialize(options = {})
      @options = options
    end

    attr_reader :options

    def publish
      zones = export_zone_files
      return false if zones.empty?
      generate_zone_clauses
      check_configuration
      reload_configuration
    end

    def export_zone_files
      zones = options[:all] ? Zone.all : Zone.stale
      puts "Exporting zones to #{self.class.zone_directory}".yellow
      FileUtils.mkdir_p(self.class.zone_directory)

      if zones.empty?
        puts "No zones were found to export".blue
        return []
      end

      zones.each do |zone|
        File.open(zone.zone_file_path, 'w') do |f|
          f.write(zone.generate_zone_file + "\n")
        end
        zone.mark_as_published
        puts "=> Exported #{zone.name}".green
      end

      zones
    end

    def generate_zone_clauses
      puts "Exporting zone clauses to #{self.class.zone_clauses_file}".yellow
      all_clauses = Zone.all.map(&:generate_zone_clause).join("\n")
      File.open(self.class.zone_clauses_file, 'w') do |f|
        f.write(all_clauses + "\n")
      end
      puts "=> Done".green
    end

    def check_configuration
      if cmd = Bound.config.bind&.commands&.check_config
        stdout, stderr, status = Open3.capture3(cmd)
        if status == 0
          true
        else
          raise PublishingError.new(:config_error, stdout + stderr)
        end
      else
        Rails.logger.warn "Cannot check configuration before not check config command has been provided.".yellow
        true
      end
    end

    def reload_configuration
      if cmd = Bound.config.bind&.commands&.reload
        stdout, stderr, status = Open3.capture3(cmd)
        if status == 0
          true
        else
          raise PublishingError.new(:reload_error, stdout + stderr)
        end
      else
        Rails.logger.warn "Cannot reload configuration before not check config command has been provided.".yellow
        true
      end
    end

    class PublishingError < StandardError
      attr_reader :error, :type

      def initialize(type, error)
        @type = type
        @error = error
      end

      def to_s
        "[#{@type}] #{@error}"
      end
    end

  end
end
