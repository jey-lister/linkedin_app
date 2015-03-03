class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
        if resource.is_a?(User)
          home_users_path
        else
          super
        end
  end

  def authenticate_user!
    session[:user].blank? ? log_out : check_user
  end

  def log_out
    reset_session
    redirect_to root_url
  end

  def check_user
    @current_user = User.find(session[:user])
    if @current_user
      set_user_sessions
    else
      log_out
    end
  end

  def set_user_sessions
    session[:user] = @current_user.id
  end

  def current_user
    @current_user || ((session[:user] && User.find(session[:user])) || (session[:user_id] && User.find(session[:user_id])))
  end
end
