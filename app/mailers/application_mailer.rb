class ApplicationMailer < ActionMailer::Base
  default :from => Bound.config.smtp.from_address
  layout false
end

