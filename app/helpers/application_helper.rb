module ApplicationHelper

  def generate_profile_json
    users_detail_hash = User.by_provider('linkedin').map do |user|
      user_info = user.detailed_profile.info
      [
          {
              :'First Name' => user_info.info.first_name,
              :'Last Name' => user_info.info.last_name,
              :'Full Name' => user_info.info.name,
              :'Title' => user_info.info.description,
              :'Location' => user_info.info.location,
              :'Industry' => user_info.info.industry,
              :'Picture' => user_info.info.image,
              :'Current Companies' => get_current_company_details(user_info),
              connections: get_connection_details(user_info, user),
              educations: get_education_details(user_info)

          }
      ]
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
      user.detailed_profile.connections.values[3].map do |connection|
        {
            :'First Name' => connection['firstName'],
            :'Last Name' => connection['lastName'],
            :'Title' => connection['title'],
            :'Location' => connection['location'] && connection['location']['name'],
            :'Picture' => connection['pictureUrl'],
            :'Positions' => connection['positions']['values'] && connection['positions']['values'].map { |position| { :'Company' => position['company'] } }
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

end
