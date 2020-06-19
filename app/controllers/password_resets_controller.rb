class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email send with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render "new"  # equivalent to: render :action => new
    end
  end

  def edit # changing of password. Email should link to this action
  end
  
  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty, dummy!")
      render 'edit'
    elsif @user.update(user_params) # if changing password successful
      @user.forget
      reset_session
      log_in @user
      @user.update_attribute(:reset_digest, nil) 
      flash[:sucess] = "Your password has been changed successfully"
      redirect_to @user
    else
      render 'edit'
    end
    
  end
  
  
  private
  
    def user_params 
      params.require(:user).permit(:password, :password_confirmation)
    end
  
    def get_user
      @user = User.find_by(email: params[:email])
    end
    
    def valid_user
      unless (@user && @user.activated? && 
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
        
    end
    
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Your password reset has unfortunately expired. Idiot!"
        redirect_to new_password_reset_url
      end
    end
end
