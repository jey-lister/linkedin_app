class UsersController < ApplicationController

  skip_before_action :authenticate_user!, only: [:login, :search_cached_linkedin_users]
  before_action :linkedin_profile_info, only: [:home, :profile_json]

  def login

  end

  def home

  end

  def search_linkedin

  end

  def search_linkedin_api
    page = params[:page] || 0
    response = RestClient.get "https://api.linkedin.com/v1/company-search?keywords=#{URI.escape(params[:search][:linked_in])}&sort=relevance&format=json&oauth2_access_token=AQVBWpbuwKV8116WxdpgdRJs4CVZavgeQdTzxoliVeEskVXP6VXmLquq_oN2NhucdqPUWxOai-KKv9XXacRgjjXtC6x5ItR_SsNpowehmSaVgvrvwHlJckAr6YcGslTYS4JXjoFPL2mSs-fQFp7OYpw7WtKSTs-dVu0b9sMSNaMc53F5ndE&start=#{page}"
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
