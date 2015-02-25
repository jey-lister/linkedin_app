# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :linkedin, '78fwejo51kryhv', '78fwejo51kryhv',
#            scope: 'r_basicprofile r_emailaddress rw_nus r_fullprofile r_contactinfo r_network rw_company_admin',
#            fields: %w(id email-address first-name last-name headline industry picture-url public-profile-url location connections skills date-of-birth phone-numbers educations three-current-positions)
# end


LinkedIn.configure do |config|
  config.client_id     = '78fwejo51kryhv'
  config.client_secret = 'aAYnkguOwwOSy3Ng'
  config.redirect_uri = 'http://localhost:3000/users/authorize_linkedin_user'
end