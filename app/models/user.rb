class User < ActiveRecord::Base

  has_one :basic_profile
  has_one :detailed_profile

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  def self.connect_to_linkedin(auth, signed_in_resource = nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      user.update_linkedin_user_info(auth)
      user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        registered_user.update_linkedin_user_info(auth)
        registered_user
      else
        create_linkedin_user_info(auth)
      end

    end
  end

  def update_linkedin_user_info(auth)
    detailed_profile ? detailed_profile.update_attributes(info: auth) : create_detailed_profile(info: auth)
  end

  def self.create_linkedin_user_info(auth)
    user = User.new(name:auth.info.first_name,
                    provider:auth.provider,
                    uid:auth.uid,
                    email:auth.info.email,
                    password:Devise.friendly_token[0,20],
    )
    user.build_basic_profile(public_profile_url: auth.info.urls.public_profile)
    user.build_detailed_profile(info: auth)
    user.save
    user
  end

end
