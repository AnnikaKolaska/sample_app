require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  
  def setup
    @user = users(:michael)
    remember(@user)   # we are pretending that he was logged in before
  end
  
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user # first expected, then actual
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    # creating random new token, hashing it and saving it as new 
    # remember_digest for our user...
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    # ...Since cookie-authentication should go wrong then, the method 
    # current_user should return nil
    assert_nil current_user
  end
end