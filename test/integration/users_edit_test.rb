require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
 
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password: "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select 'div.alert', text: 'The form contains 4 errors.' 
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    assert_not_nil session[:forwarding_url]
    log_in_as(@user) 
    #assert_template 'users/edit' was before here
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty? # there should be an edit-successfull message
    assert_redirected_to @user
    @user.reload   # takes/reloads the information of the user from the database.
    assert_equal name, @user.name
    assert_equal email, @user.email
    assert_nil session[:forwarding_url]
  end
  
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url 
  end
  
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
                                              
    assert flash.empty?
    assert_redirected_to root_url
  end
  
end
