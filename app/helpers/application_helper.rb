module ApplicationHelper

  def generate_profile_json
    users_detail_hash = User.by_provider('linkedin').map do |user|
      user_info = user.detailed_profile.info

        {
            :'First Name' => user.first_name,
            :'Last Name' => user.last_name,
            :'Title' => user.headline,
            connections: get_connection_details(user_info, user)

        }

    end
    users_detail_hash.to_json
  end

  def get_connection_details(user_info, user)
    if user.detailed_profile.connections.blank?
      user_info.extra.raw_info.connections.values[3] && user_info.extra.raw_info.connections.values[3].map do |connection|
        {
            :'First Name' => connection.firstName,
            :'Last Name' => connection.lastName,
            :'Head Line' => connection.headline,
            :'Location' => connection.location.try(:name),
            :'Picture' => connection.pictureUrl,
            :'Industry' => connection.location.try(:industry)
        }
      end
    else
      available_connections = user.detailed_profile.connections.values.last
      available_connections.map do |connection|
        {
            :'First Name' => connection['firstName'],
            :'Last Name' => connection['lastName'],
            :'Title' => connection['title'],
            :'Location' => connection['location'] && connection['location']['name'],
            :'Picture' => connection['pictureUrl'],
            :'Positions' => connection['positions'] && connection['positions']['values'] && connection['positions']['values'].map { |position| { :'Company' => position['company'] } }
        }
      end
    end

  end

  def get_education_details(user_info)
    user_info.extra.raw_info.educations.values[1] && user_info.extra.raw_info.educations.values[1].map do |education|
      {
          :'Degree' => education.degree,
          :'Field of Study' => education.fieldOfStudy,
          :'Institution' => education.schoolName,
          :'Start Date' => education.startDate.try(:year),
          :'End Date' => education.endDate.try(:year)
      }
    end
  end

  def get_current_company_details(user_info)
    user_info.extra.raw_info['threeCurrentPositions'].values[1] && user_info.extra.raw_info['threeCurrentPositions'].values[1].map do |company|
      {
          :'Company Name' => company.try(:company).try(:name),
          :'Title' => company.try(:title),
          :'Summary' => company.try(:summary),
          :'Start Date' => company.try(:startDate).try(:year)
      }
    end
  end

  def matched_connection_json(user, match_string)
    user.detailed_profile.connections.values.last.reject do |connection|
      match_parser = connection['positions'] && connection['positions']['values'] && connection['positions']['values'].map do |company|
        company['company'] && company['company']['name'].try(:downcase).try(:include?, match_string.downcase)
      end
      !match_parser.try(:include?, true)
    end
  end

  def matched_companies(matched_users, match_string)
    matched_company_ids = matched_users.map do |user|
      matched_connection_json(user, match_string).map do |conn|
        conn['positions']['values'].map do |position|
          position['company']['id']
        end
      end
    end

    matched_company_ids = matched_company_ids.flatten.uniq.compact

    matched_company_ids.map do |company_id|
      company = LinkedinCompany[company_id]
      fetched_profile = RestClient.get "https://api.linkedin.com/v1/companies/#{company_id}:(id,name,universal-name,email-domains,company-type,ticker,website-url,industries,status,logo-url,square-logo-url,blog-rss-url,twitter-id,employee-count-range,specialties,locations,description,stock-exchange,founded-year,end-year,num-followers)?format=json&oauth2_access_token=#{ENV['LINKEDIN_OAUTH2_TOKEN']}"

      if company
        company.update_attributes(profile: fetched_profile)
      else
        company = LinkedinCompany.create(company_id: company_id, profile: fetched_profile)
      end
      company
    end
  end

end
