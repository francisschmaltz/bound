source 'https://rubygems.org'

gem 'rails', '~> 5.0.0'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'bcrypt', '~> 3.1.7'
gem 'haml'
gem 'nifty-utils'
gem 'nilify_blanks'
gem 'authie'
gem 'kaminari'
gem 'hashie'
gem 'dynamic_form'
gem 'omniauth'
gem 'foreman'
gem 'nissh'
gem 'net-sftp', :require => 'net/sftp'
gem 'moonrope'
gem 'autoprefixer-rails', '~> 6.4'

require_relative './lib/bound/config'
if Bound.yaml_config['auth'] && strategy = Bound.yaml_config['auth']['strategy']
  gem "omniauth-#{strategy}"
end

group :development, :test do
  gem 'byebug'
  gem 'annotate'
end
