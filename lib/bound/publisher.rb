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
      @zones = options[:all] ? Zone.all : Change.pending.includes(:zone).map(&:zone).uniq.compact
      @result = PublishResult.new
    end

    attr_reader :options
    attr_reader :result
    attr_reader :zones

    def publish
      validate_zone_files
      return unless result.zone_file_errors.empty?
      export_zone_files
      remove_deleted_zones
      generate_zone_clauses
      if check_configuration && reload_configuration && mark_as_published
        copy_zone_clauses_to_slaves
      end
    end

    def validate_zone_files
      puts "Validating #{@zones.size} zone file(s)"
      @zones.each do |zone|
        if errors = zone.zone_file_errors
          result.zone_file_errors[zone] = errors
          puts "=> Zone file for #{zone.name} has errors".red
        else
          puts "=> Zone file for #{zone.name} is OK".green
        end
      end
    end

    def export_zone_files
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

    def copy_zone_clauses_to_slaves
      return unless Bound.config.replication
      puts "Copying zone clauses to slaves"
      clauses = Zone.all.map(&:generate_zone_clause_for_slave).join("\n") + "\n"
      sha = Digest::SHA1.hexdigest(clauses)
      for slave in Bound.config.replication.slaves
        puts "=> Publishing to #{slave.ip_address}"
        ssh = Nissh::Session.new(slave.ip_address, slave.username, :keys => slave.key_path ? [slave.key_path] : [], :port => slave.ssh_port)

        # Check to see if we need a new zone file if we're not doing a force
        unless @options[:all]
          cmd_result = ssh.execute!("sha1sum #{slave.zone_file_path}")
          if cmd_result.success? && cmd_result.stdout =~ /\A#{sha}\s+/
            puts "   No zone file needed for this slave.".blue
            result.slaves[slave.ip_address] = {:success => nil, :text => "No zone file changes needed"}
            next
          end
        end

        # Upload a new file
        ssh.session.sftp.file.open(slave.zone_file_path, 'w') { |f| f.write(clauses) }
        puts "   Uploaded new zone file to #{slave.zone_file_path}".green

        # Reload configuration
        cmd_result = ssh.execute!(slave.reload_command)
        if cmd_result.success?
          puts "   Reloaded BIND on slave".green
          result.slaves[slave.ip_address] = {:success => true, :text => "reloaded successfully"}
        else
          puts "   Couldn't reload configuration. Check result.".red
          result.slaves[slave.ip_address] = {:success => false, :text => cmd_result.output}
        end
      end
    end

  end
end

