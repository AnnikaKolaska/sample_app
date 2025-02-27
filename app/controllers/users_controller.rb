class UsersController < ApplicationController
  # restricts the filter to act only on the :index, :edit, :update and destroy actions
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy,
                                        :following, :followers] 
  
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def new
    @user = User.new  # first creating empty user here (signup page)
  end
  
  def show  # user profile-page
    @user = User.find(params[:id])   
    @microposts = @user.microposts.paginate(page: params[:page]) 
    redirect_to root_url and return unless @user.activated?
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url 
    else
      render "new"
    end
  end
  
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit"
    end
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:sucess] = "User delete"
    redirect_to users_url
  end
  
  def following   # Railsconvention: route we want is following_user_path(@user), similar to show
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  
  
  
  private
    # Im constantly not seeing this method and searching for it like an idiot, 
    # here should be a comment
    # Returns all relevant and permitted attributes of the user. 
    # Strong parameters which prevent a mass assignment vulnarability.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    
    # Before filters
    
    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])  # getting the user of the profilepage (frontend)
      redirect_to(root_url) unless current_user?(@user) # checking if the current_user really is the owner of the profilepage.
    end
    
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
