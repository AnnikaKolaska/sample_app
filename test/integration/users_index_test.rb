require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
  
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.first.toggle!(:activated) #changes user IN THE DATABASE
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    #first_page_of_users.each do |user|  # BEFORE Exercise
    
    assigns(:users).each do |user|#access the value of @users in the action!!!
      assert user.activated? # because only activated users should be shown
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin # if user not admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do  # should be true...
      delete user_path(@non_admin)      # if we do ...
    end
  end
  
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete' , count: 0
  end
  
end
