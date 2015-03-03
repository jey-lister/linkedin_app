LinkedIn.configure do |config|
  config.client_id     = '78fwejo51kryhv'
  config.client_secret = 'aAYnkguOwwOSy3Ng'
  config.redirect_uri = "#{ENV['SITE_URL']}/users/authorize_linkedin_user"
end

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :salesforce, ENV['SALESFORCE_APP_ID'], ENV['SALESFORCE_APP_SECRET']
end