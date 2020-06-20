require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:michael)
    @mipo = @user.microposts.build(content: "Lorem ipsum")
  end
    
  test "should be valid" do
    assert @mipo.valid?
  end
    
  test "user id should be present" do
    @mipo.user_id = nil
    assert_not @mipo.valid?
  end
  
  test "content should be present" do
    @mipo.content = "     "
    assert_not @mipo.valid?
  end
  
  test "content should be no longer then 140 characters" do
    @mipo.content = "a" * 141
    assert_not @mipo.valid?
  end
  
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
end

