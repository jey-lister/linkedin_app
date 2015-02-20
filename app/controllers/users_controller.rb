class UsersController < ApplicationController

  def home
    @linked_in = current_user.detailed_profile.info
  end

  def search_linkedin
    
  end

end
