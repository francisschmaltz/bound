class UserMailer < ApplicationMailer

  def user_invite(user)
    @user = user
    mail :to => user.email_address, :subject => "You've been invited to access Bound"
  end

end
