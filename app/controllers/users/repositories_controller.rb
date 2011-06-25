class Users::RepositoriesController < ApplicationController

  before_filter :authenticate_user!

  inherit_resources

  actions :new, :create

  respond_to :html

  def create
    create!(:notice => "Repository successfully created.") do
      user_repository_root_path :user_id => current_user, :repository_id => resource if resource.persisted?
    end
  end

  protected

  def end_of_association_chain
    current_user.repositories
  end

end
