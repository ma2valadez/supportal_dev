class ProtectedPagesController < ApplicationController
  before_action :logged_in_user

  def show
    # Your protected page logic here
  end
end
