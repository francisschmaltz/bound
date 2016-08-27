class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :login_required

  private

  def login_required
    unless logged_in?
      redirect_to login_path
    end
  end
end
