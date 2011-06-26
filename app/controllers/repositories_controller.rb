class RepositoriesController < ApplicationController

  Error = Class.new(StandardError)

  attr_reader   :owner, :repository
  helper_method :owner, :repository, :current_path

  before_filter :prepare_owner
  before_filter :prepare_repository

  def edit
    authorize! :update, repository
  end

  def update
    authorize! :update, repository
    if repository.update_attributes params[:repository]
      redirect_to :action => 'tree'
    else
      render :action => :edit
    end
  end

  def commits
  end

  def commit
  end

  def tree
    @tree = extract_relevant_tree repository.to_grit.tree(current_ref)
  end

  def blob
    @tree = extract_relevant_tree repository.to_grit.tree(current_ref), current_path[0..-2]
    @blob = @tree / current_path.last
    check_type! @blob, Grit::Blob
  end

  def raw
  end

  private

  def prepare_owner
    source = request.path_parameters
    if source.has_key?(:user_id)
      @owner = @user = User.find_using_slug!(source[:user_id])
    else # Fallback to other
      raise ActiveRecord::RecordNotFound
    end
  end

  def prepare_repository
    @repository = owner.repositories.find_using_slug!(params[:repository_id])
  end

  def current_ref
    @current_ref ||= (params[:ref] == :default ? repository.manager.head : params[:ref])
  end

  def current_path
    params[:path].blank? ? [] : params[:path].split("/").reject { |v| v.blank? or %w(. ..).include?(v) }
  end

  def extract_relevant_tree(tree, path = current_path)
    check_type! tree
    path.each do |subpath|
      tree = tree / subpath
      check_type! tree
    end
    tree
  end

  def check_type!(entry, type = Grit::Tree)
    raise Error, 'Unknown object' unless entry.presence.is_a?(type)
  end

end
