class UsersController < ApplicationController

  def home
    @linked_in = current_user.detailed_profile.info
  end

  def search_linkedin

  end

  def search_linkedin_api
    page = params[:page] || 10
    response = RestClient.get "https://api.linkedin.com/v1/company-search?keywords=#{params[:search][:linked_in]}&sort=relevance&format=json&oauth2_access_token=AQVBWpbuwKV8116WxdpgdRJs4CVZavgeQdTzxoliVeEskVXP6VXmLquq_oN2NhucdqPUWxOai-KKv9XXacRgjjXtC6x5ItR_SsNpowehmSaVgvrvwHlJckAr6YcGslTYS4JXjoFPL2mSs-fQFp7OYpw7WtKSTs-dVu0b9sMSNaMc53F5ndE&start=#{page}"
    @result = JSON.parse response
  end

end
