require 'yaml'
require 'pathname'

module Bound

  def self.app_root
    @app_root ||= Pathname.new(File.expand_path('../../../', __FILE__))
  end

  def self.config
    @config ||= begin
      require 'hashie/mash'
      Hashie::Mash.new(yaml_config)
    end
  end

  def self.config_root
    @config_root ||= begin
      if __FILE__ =~ /\A\/opt\/bound/
        Pathname.new("/opt/bound/config")
      else
        Pathname.new(File.expand_path("../../../config", __FILE__))
      end
    end
  end

  def self.config_file_path
    @config_file_path ||= File.join(config_root, 'bound.yml')
  end

  def self.yaml_config
    @yaml_config ||= File.exist?(config_file_path) ? YAML.load_file(config_file_path) : {}
  end

  def self.set_database_url
    if config.mysql
      ENV['DATABASE_URL'] = "mysql2://#{config.mysql.username}:#{config.mysql.password}@#{config.mysql.host}:#{config.mysql.port}/#{config.mysql.database}"
    else
      ENV['DATABASE_URL'] = "mysql2://root@localhost/bound"
    end
  end

end
