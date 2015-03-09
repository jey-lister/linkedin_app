namespace :linkedin do

  namespace :updates do

    desc 'Update connection info for already logged in users with pre stored oauth2_access_token'
    task :connection_info => :environment do

      User.by_provider('linkedin').each do |user|
        oauth2_access_token = user.oauth2_access_token
        user_existing_connections = user.detailed_profile.connections
        user_new_connections = JSON.parse RestClient.get("https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,headline,location,picture-url,site-standard-profile-request,positions)?oauth2_access_token=#{oauth2_access_token}&format=json")

        connection_difference = JsonCompare.get_diff(user_existing_connections, user_new_connections)
        puts connection_difference.to_json
      end

    end

  end

end