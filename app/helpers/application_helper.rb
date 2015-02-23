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
              connections: get_connection_details(user_info),
              educations: get_education_details(user_info)

          }
      ]
    end
    users_detail_hash.to_json
  end

  def get_connection_details(user_info)
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

end
