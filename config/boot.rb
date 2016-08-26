ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require_relative '../lib/bound/config'
Bound.set_database_url

if Bound.config.rails && Bound.config.rails.environment
  ENV['RAILS_ENV'] = Bound.config.rails.environment
end
