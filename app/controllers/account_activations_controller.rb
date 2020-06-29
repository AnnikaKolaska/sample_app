class AccountActivationsController < ApplicationController
  
  # the standard REST practice is to issue a PATCH request to the update action. The activation
  # link needs to be sent in an email, though, and hence will involve a regular browser click, 
  # which issues a GET request instead of PATCH. This design constraint means that we can’t use the update action.
  def edit
    # Example: With a service 
    # user = ActivateUser.execute(params)
    # if user.present?
    #   flash[:success] = "Account activated!"
    #   redirect_to user
    # else
    #   flash[:danger] = "Invalid activation link"
    #   redirect_to root_url
    # end
    # Example: With a module
    # user = User.find_by(email: params[:email])
    # if user.activate(params[:id])
    #   flash[:success] = "Account activated!"
    #   redirect_to user
    # else
    #   flash[:danger] = "Invalid activation link"
    #   redirect_to root_url
    # end
    
    user_activation = UserActivation.new(user)
    if user && user_activation.activable?(params[:id])
      user_activation.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
  
  
  
end
