class CollaborationsController < ApplicationController
  require 'repository_loader'
  include RepositoryLoader
  
  before_filter :authenticate_user!
  before_filter :check_repository_authorization!
  
  inherit_resources
  load_and_authorize_resource :collaboration
  
  actions :create, :destroy
  
  def create
    create!(:notice => "Collaborator successfully added.") do
      contextual_repo_path(owner, repository, :edit) if resource.persisted?
    end
  end
  
  def destroy
    destroy!(:notice => "Collaborator successfully remove.") do
      contextual_repo_path(owner, repository, :edit)
    end
  end
  
  private
  
  def check_repository_authorization!
    authorize! :update, repository
  end
  
  def end_of_association_chain
    repository.collaborations
  end
  
end
