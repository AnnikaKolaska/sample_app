class UserActivation
  #attr_accessor :user    # this here yes or no??
  
  def initialize(user)
    @user = user
  end
  
  def activable?(activation_token)
    !@user.activated? && @user.authenticated?(:activation, activation_token)
  end  
  
  # Activates an account.
  def activate
    @user.update_columns(activated: true, activated_at: Time.zone.now)
  end
  
end