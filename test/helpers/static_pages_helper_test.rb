require 'test_helper' 

class StaticPagesHelperTest < ActionView::TestCase
  
  test "full title helper" do 
    assert_equal full_title, "Ruby on Rails Tutorial Sample App" 
    assert_equal full_title("HELP"), "HELP | Ruby on Rails Tutorial Sample App" 
  end
  
end