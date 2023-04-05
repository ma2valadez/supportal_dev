require "test_helper"

class ProtectedPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "should redirect if user is not logged in" do
    get welcome_url
    assert_redirected_to login_url
  end
end
