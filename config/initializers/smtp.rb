require 'bound/config'
if Bound.config&.smtp
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {:address => Bound.config.smtp.host, :user_name => Bound.config.smtp.username, :password => Bound.config.smtp.password}
end
