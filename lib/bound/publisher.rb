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
      @zones = []
      @result = PublishResult.new
    end

    attr_reader :options
    attr_reader :result
    attr_reader :zones

    def publish
      export_zone_files
      remove_deleted_zones
      generate_zone_clauses
      check_configuration && reload_configuration && mark_as_published
      result
    end

    def export_zone_files
      @zones = options[:all] ? Zone.all : Change.pending.includes(:zone).map(&:zone).uniq.compact
      puts "Exporting zones to #{self.class.zone_directory}"
      FileUtils.mkdir_p(self.class.zone_directory)

      if @zones.empty?
        puts "=> No zones with pending changes were found to export".green
        return []
      end

      @zones.each do |zone|
        File.open(zone.zone_file_path, 'w') do |f|
          f.write(zone.generate_zone_file + "\n")
        end
        puts "=> Exported #{zone.name}".green
        result.zone_files_exported  << zone.zone_file_path
      end
    end

    def remove_deleted_zones
      puts "Removing unused deleted zone files"
      existing_files = Dir[File.join(self.class.zone_directory, "*")].map { |f| f.split('/').last }
      required_files = Zone.all.map { |z| "#{z.name}.zone" }
      superfluous_files = (existing_files - required_files).map { |f| "#{self.class.zone_directory}/#{f}" }
      if superfluous_files.empty?
        puts "=> No superfluous files found to remove".green
      else
        superfluous_files.each do |file|
          FileUtils.rm(file)
          puts "=> Removed #{file}".green
          result.zone_files_deleted << file
        end
      end
    end

    def generate_zone_clauses
      puts "Exporting zone clauses to #{self.class.zone_clauses_file}"
      all_clauses = Zone.all.map(&:generate_zone_clause).join("\n")
      File.open(self.class.zone_clauses_file, 'w') do |f|
        f.write(all_clauses + "\n")
      end
      puts "=> Done".green
    end

    def check_configuration
      if cmd = Bound.config.bind&.commands&.check_config
        puts "Checking configuration"
        stdout, stderr, status = Open3.capture3(cmd)
        if status == 0
          puts "=> Configuration OK".green
          result.configuration_check = true
        else
          puts "=> Configuration not OK".red
          result.configuration_errors = stdout + stderr
          result.configuration_check = false
        end
      else
        Rails.logger.warn "Cannot check configuration before not check config command has been provided."
        true
      end
    end

    def reload_configuration
      if cmd = Bound.config.bind&.commands&.reload
        puts "Reloading configuration"
        stdout, stderr, status = Open3.capture3(cmd)
        if status == 0
          puts "=> Reloading OK".green
          result.reload = true
        else
          puts "=> Reloading not OK".red
          result.reload = false
        end
      else
        Rails.logger.warn "Cannot reload configuration before not check config command has been provided."
        result.reload = false
      end
    end

    def mark_as_published
      time = Time.now
      @zones.each do |zone|
        zone.mark_as_published(time)
      end
      Change.pending.update_all(:published_at => time)
    end

  end
end

