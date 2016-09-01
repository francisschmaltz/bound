class AuthenticationController < ApplicationController

  skip_before_filter :login_required, :only => [:login, :callback, :join, :logout]

  def login
    if User.count > 0
      redirect_to "/auth/#{Bound.config.auth.strategy}"
    else
      render 'welcome'
    end
  end

  def callback
    if session[:invite_token] && user = User.pending.where(:invite_token => session[:invite_token]).first!
      if existing_user = User.where(:provider => auth_hash.provider, :uid => auth_hash.uid).first
        user.destroy
        do_login existing_user, :flash => "The authenticated user already exists so this has been used."
      else
        user.copy_attributes_from_auth_hash!(auth_hash)
        do_login user
      end
    elsif user = User.find_from_auth_hash(auth_hash)
      do_login user
    else
      render :plain => "You are not permitted to access the application. You should ask the application owner to provide you with access."
    end
  ensure
    session[:invite_token] = nil
  end

  def logout
    if request.delete?
      auth_session.invalidate! if logged_in?
      reset_session
      redirect_to logout_path
    end
  end

  def join
    User.pending.where(:invite_token => params[:invite_token]).first!
    session[:invite_token] = params[:invite_token]
  end

  private

  def do_login(user, options = {})
    self.current_user = user
    flash[:notice] = options[:flash] || "You have been logged in as #{user.name} using #{Bound.config.auth.description}"
    redirect_to root_path
  end

  def auth_hash
    request.env['omniauth.auth']
  end

end
