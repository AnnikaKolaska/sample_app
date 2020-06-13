class SessionsController < ApplicationController
  
  def new
    
  end
  
  def create
    posted_user_email = params[:session][:email].downcase
    posted_user_password = params[:session][:password]
    user = User.find_by(email: posted_user_email)  #returns true if the user exists
    if user &. authenticate(posted_user_password)
      reset_session   # keeps an attacker from being able to share the session
      log_in user
      redirect_to user # somehow automatically knows that we want a redirection to the users profile page/ user_url(user)
    else
      flash.now[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end
  
  def destroy
    log_out
    redirect_to root_url  # with redirect_to we use _url not _path
  end
  
end
