require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@firstup.io",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    # assert_not flash.nil?
    assert is_logged_in?
  end
end