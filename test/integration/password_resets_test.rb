require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
  
  test "password resets" do
    get new_password_reset_path   # forgot password view
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Invalid email
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit' # DONT FORGET this is not url this is controller/action
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
        params: { email: user.email,
                  user: { password: "foobaz",
                  password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # Empty password
    patch password_reset_path(user.reset_token),
        params: { email: user.email,
                  user: { password: "",
                  password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
        params: { email: user.email,
                  user: { password: "foobaz",
                  password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
  
  test "expired token" do
    get new_password_reset_path      # Forgot my password view
    post password_resets_path,       # typing in ones e-mail
        params: { password_reset: { email: @user.email } }
    @user = assigns(:user)           # getting instancevariable so we can access virtual attribute reset_token
    # trying to get to edit_password_reset(@user.reset_token) is missing BUT the before filters are the same.
    @user.update_attribute(:reset_send_at, 3.hours.ago)  # make the activationlink expired
    patch password_reset_path(@user.reset_token),     # trying to change passworde(update action) to the page the email links to; reset_token is like an id.
        params: { email: @user.email,                 
                   user: { password: "foobar",
                           password_confirmation: "foobar" } }
    assert_response :redirect   # should notice that activationtoken expired and redirect.
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
