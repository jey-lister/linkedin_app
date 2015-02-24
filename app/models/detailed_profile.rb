class DetailedProfile < ActiveRecord::Base

  belongs_to :user

  serialize :info, Hash

  def connections
    super && JSON.parse(super)
  end

end
