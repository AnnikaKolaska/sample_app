class MicropostsController < ApplicationController

  before_action :logged_in_user, only: [:create, :destroy]
  # when we have a logged_in user we can get him with the method current_user
  before_action :correct_user, only: :destroy
    
  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted!"
    if request.referrer.nil? || request.referrer == microposts_url
      redirect_to root_url
    else
      redirect_to request.referrer
    end
  end
  
  private
    
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end
    
    # BEWARE the frickin server has visual bugs sometimes showing always the same id,
    # namely the user_id instead of the micropost_id in the paramshash in the console
    # where the server is running.
    def correct_user 
      # if we can find the post by the id inside of all of the microposts of the current_user
      # then we know that the post actually belonged to him.
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
  
end
