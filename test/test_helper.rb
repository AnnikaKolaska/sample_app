ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper
  include StaticPagesHelper
  # we could actually just include the Sessions helper and use logged_in? directly, 
  # but this technique would fail in Chapter 9 due to details of how cookies are handled in tests
  
  # Add more helper methods to be used by all tests here... 
  
  # Returns true if ANY test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end
  
end
