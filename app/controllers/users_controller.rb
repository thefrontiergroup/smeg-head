class UsersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :prepare_user, only: [:show]

  def show
    @repositories = @user.repositories.publically_accessible
  end

  protected

  def prepare_user
    @user = User.find_using_slug(params[:id])
  end

end
