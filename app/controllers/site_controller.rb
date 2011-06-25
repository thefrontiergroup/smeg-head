class SiteController < ApplicationController

  respond_to :html

  before_filter :authenticate_user!, :only => :dashboard

  def index
  end

  def dashboard
    @repositories = current_user.repositories.all
  end

end
