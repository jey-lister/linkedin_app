class Home < ActiveRecord::Base

  validates :object, uniqueness: true

end
