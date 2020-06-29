class SessionsController < ApplicationController
  
  def new
    
  end
  
  def create
    posted_user_email = params[:session][:email].downcase
    posted_user_password = params[:session][:password]
    # user as instancevariable = we can access remember token in tests
    @user = User.find_by(email: posted_user_email)  #returns true if the user exists
    if @user&.authenticate(posted_user_password)
      if @user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session   # keeps an attacker from being able to share the session
        log_in @user
        # before: remember user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        session[:session_token] = @user.session_token 
        redirect_to forwarding_url || @user # somehow automatically knows that we want a redirection to the users profile page/ user_url(user)
      else
        message = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end  
    else
      flash.now[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url  # with redirect_to  use ..._url not ..._path
  end
  
end
