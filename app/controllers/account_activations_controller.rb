class AccountActivationsController < ApplicationController
  
  # the standard REST practice is to issue a PATCH request to the update action. The activation
  # link needs to be sent in an email, though, and hence will involve a regular browser click, 
  # which issues a GET request instead of PATCH. This design constraint means that we can’t use the update action.
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
  
  
  
end
