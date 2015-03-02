class User < ActiveRecord::Base

  has_one :basic_profile
  has_one :detailed_profile

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :omniauthable

  scope :by_provider, -> (provider) { where(provider: provider) }
  scope :by_uid, -> (uid) { where(uid: uid) }

  def full_name
    "#{first_name} #{last_name}".squeeze(' ')
  end

  def self.login_with_linkedin(oauth2_access_token)
    basic_profile = JSON.parse RestClient.get("https://api.linkedin.com/v1/people/~?oauth2_access_token=#{oauth2_access_token}&format=json")
    user = User.by_uid(basic_profile['id']).first
    if user.blank?
      user = User.create!(uid: basic_profile['id'])
    end
    connections = RestClient.get("https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,headline,location,picture-url,site-standard-profile-request,positions)?oauth2_access_token=#{oauth2_access_token}&format=json")
    user.update_attributes(first_name: basic_profile['firstName'], last_name: basic_profile['lastName'], oauth2_access_token: oauth2_access_token, :headline => basic_profile['headline'], provider: 'linkedin')
    user.update_linkedin_connection_info(connections)
    user.detailed_profile.save
    user
  end

  def update_linkedin_user_info(auth)
    detailed_profile ? detailed_profile.update_attributes(info: auth) : create_detailed_profile(info: auth)
  end

  def update_linkedin_connection_info(connections)
    detailed_profile ? detailed_profile.update_attributes(connections: connections) : create_detailed_profile(connections: connections)
  end

  def connections_company_names
    detailed_profile && detailed_profile.connections['values'] && detailed_profile.connections['values'].map do |connection|
      connection['positions'] && connection['positions']['values'] && connection['positions']['values'].map { |c| c['company'] && c['company']['name'] }
    end
  end

  def company_matched?(match_string)
    flag = false
    connections_company_names && connections_company_names.compact.map do |name|
      name.each do |n|
        flag = true if n && n.downcase.include?(match_string.downcase)
        break if flag
      end
      break if flag
    end
    flag
  end

end
