class UsersController < ApplicationController

  skip_before_action :authenticate_user!, only: [:login, :search_cached_linkedin_users, :sign_in_with_linked_in, :authorize_linkedin_user]
  before_action :linkedin_profile_info, only: [:home, :profile_json]

  def login

  end

  def sign_in_with_linked_in
    oauth = LinkedIn::OAuth2.new
    url = oauth.auth_code_url
    redirect_to url
  end

  def authorize_linkedin_user
    oauth = LinkedIn::OAuth2.new
    code = params[:code]
    access_token = oauth.get_access_token(code)
    @current_user = User.login_with_linkedin(access_token.token)
    set_user_sessions
    redirect_to action: :home
  end

  def home

  end

  def search_linkedin

  end

  def search_linkedin_api
    page = params[:page] || 0
    response = RestClient.get "https://api.linkedin.com/v1/company-search?keywords=#{URI.escape(params[:search][:linked_in])}&sort=relevance&format=json&oauth2_access_token=#{current_user.oauth2_access_token}&start=#{page}"
    @result = JSON.parse response
  end

  def profile_json

  end

  def search_cached_linkedin_users
    @matched_users = matched_users.compact
  end

  private

  def linkedin_profile_info
    @linked_in = current_user.detailed_profile.info
  end

  def matched_users
    User.by_provider('linkedin').map do |user|
      user if user.company_matched?(params[:search][:linked_in])
    end
  end

end
