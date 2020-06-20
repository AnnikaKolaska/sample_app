class ApplicationController < ActionController::Base
  include SessionsHelper
  
  private
  
    # Confirms a logged-in user or stores the requested url for
    # friendly redirection after logging in.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
