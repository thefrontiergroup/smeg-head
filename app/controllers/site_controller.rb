class SiteController < ApplicationController

  respond_to :html

  before_filter :authenticate_user!, :only => :dashboard

  def index
    @repositories = Repository.publically_accessible
  end

  def dashboard
    @repositories = current_user.repositories.all
  end

end
