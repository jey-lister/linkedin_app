class UsersController < ApplicationController

  skip_before_action :authenticate_user!, only: [:login, :search_cached_linkedin_users, :sign_in_with_linked_in, :authorize_linkedin_user, :lan, :search]
  before_action :linkedin_profile_info, only: [:home, :profile_json]

  def login

  end

  def sign_in_with_linked_in
    oauth = LinkedIn::OAuth2.new
    url   = oauth.auth_code_url
    redirect_to url
  end

  def authorize_linkedin_user
    oauth         = LinkedIn::OAuth2.new
    code          = params[:code]
    access_token  = oauth.get_access_token(code)
    @current_user = User.login_with_linkedin(access_token.token)
    session[:user] = @current_user.id
    set_user_sessions
    redirect_to action: :home
  end

  def home

  end

  def search_linkedin

  end

  def search_linkedin_api
    params[:page] ||= '0'
    page_offset   = params[:page].to_i * 10
    response      = RestClient.get "https://api.linkedin.com/v1/company-search?keywords=#{URI.escape(params[:search][:linked_in])}&sort=relevance&format=json&oauth2_access_token=#{current_user_linkedin.oauth2_access_token}&start=#{page_offset}"
    @result       = JSON.parse response
  end

  def profile_json

  end

  def profile_json1

  end

  def search_cached_linkedin_users
    @matched_users = matched_users.compact
    @matched_sf_users = matched_sf_users.compact
  end

  def search_linkedin_users

  end

  def search_linkedin_users_api
    params[:page] ||= '0'
    page_offset   = params[:page].to_i * 25
    response = RestClient.get "https://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,public-profile-url,three-current-positions:(title,company:(name,industry)),distance,picture-url,relation-to-viewer))?oauth2_access_token=#{params[:search][:key]}&company-name=#{URI.escape(params[:search][:linked_in])}&facet=network%2CS&count=25&sort=relevance&format=json&start=#{page_offset}"
    @result       = JSON.parse response
  end

  def lan
    if current_user
      client = Restforce.new :oauth_token => current_user.oauth_token,
                             :refresh_token => current_user.refresh_token,
                             :instance_url => current_user.instance_url,
                             :client_id => Rails.application.config.salesforce_app_id,
                             :client_secret => Rails.application.config.salesforce_app_secret

      #user info
      @user_info = client.query("select Id, Name from User")
      @user_info_hash = Hash.new
      @user_info.each { |info| @user_info_hash.merge!("#{info['Id']}" => "#{info['Name']}") }
      @user_info_hash

      #account info
      @account_info = client.query("select Id, Name from Account")
      @acc_info_hash = Hash.new
      @account_info.each { |info| @acc_info_hash.merge!("#{info['Id']}" => "#{info['Name']}") }
      @acc_info_hash

      #opportunity info
      @opp_info = client.query("select ownerid, accountid, Name from Opportunity")
      @opp_info_hash = Hash.new
      @opp_info.each { |info|
        if @opp_info_hash.has_key?("#{info['AccountId']}")
          @opp_info_hash["#{info['AccountId']}"].push("#{@user_info_hash["#{info['OwnerId']}"]}")
        else
          @opp_info_hash["#{info['AccountId']}"] = Array.new
          @opp_info_hash["#{info['AccountId']}"].push("#{@user_info_hash["#{info['OwnerId']}"]}")
        end
      }
      @opp_info_hash

      #storing opportunity
      @opp_name_hash = Hash.new
      @opp_info.each { |info|
        if @opp_name_hash.has_key?("#{info['AccountId']}")
          @opp_name_hash["#{info['AccountId']}"].push("#{info['Name']}")
        else
          @opp_name_hash["#{info['AccountId']}"] = Array.new
          @opp_name_hash["#{info['AccountId']}"].push("#{info['Name']}")
        end
      }
      @opp_name_hash

      #json generation
      @json_output = Array.new
      a = Array.new
      @opp_info_hash.select { |key, value|
        @json_output << ({'account' => "#{@acc_info_hash[key]}",'opportunity' => "#{@opp_name_hash[key]}", 'users' => value.uniq})
      }

      @save_object = Home.new(:object => @json_output.to_json)
      @save_object.save
      #@json_output = @json_output.to_json
    end
  end

  def search
    search_text = params['text'].downcase
    search_result = Home.all
    @match_json = search_result.map do |jsn|
      if jsn.object.downcase.include? search_text
        JSON.parse jsn.object
      end
    end
    @match_json = @match_json.compact.to_json
  end

  private

  def linkedin_profile_info
    @linked_in = current_user_linkedin.detailed_profile.info
  end

  def matched_users
    User.by_provider('linkedin').map do |user|
      user if user.company_matched?(params[:search][:linked_in])
    end
  end

  def matched_sf_users
    ret_json = Home.all.map do |obj|
      parsed_json = JSON.parse(obj.object)
      check_occurrence = parsed_json.map do |ol|
        ol['account'].downcase.include?(params[:search][:linked_in].downcase)
      end
      parsed_json if check_occurrence.try(:include?, true)
    end

    ret_json.compact.map do |sf_user|
      sf_user.reject do |sf_user_ind|
        !sf_user_ind['account'].downcase.include?(params[:search][:linked_in].downcase)
      end
    end
  end

end
