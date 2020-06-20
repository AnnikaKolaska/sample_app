require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @mipo = microposts(:orange)
  end
 
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem" } }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@mipo)
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy for wrong micropost" do
    @ants_mipo = microposts(:ants)
    @wrong_user = users(:michael)
    log_in_as(@wrong_user)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@ants_mipo)
    end
    assert_redirected_to root_url
  end
  
end
