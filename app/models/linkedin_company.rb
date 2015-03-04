class LinkedinCompany < ActiveRecord::Base

  validates :company_id, uniqueness: true

  lazy_attribute :company_id

  def profile
    super && JSON.parse(super)
  end

end
