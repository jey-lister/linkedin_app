class SessionsController < ApplicationController

  skip_before_action :authenticate_user!

  def create
    user              = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to lan_users_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
