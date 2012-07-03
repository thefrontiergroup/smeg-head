class RepositoriesController < ApplicationController
  require 'repository_loader'
  include RepositoryLoader

  Error = Class.new(StandardError)

  helper_method :current_path

  def edit
    authorize! :update, repository
    render 'users/repositories/edit'
  end

  def update
    authorize! :update, repository
    if repository.update_attributes params[:repository]
      redirect_to contextual_repo_path(owner, repository, :edit)
    else
      render :action => :edit
    end
  end

  def destroy
    authorize!  :destroy, repository
    repository.destroy
    redirect_to :root
  end

  def commits
  end

  def commit
  end

  def tree
    @tree = @branch = current_branch
    if @tree
      @tree = @branch/current_path.join('/') unless current_path.empty?
    end
    if !@tree
      render 'no_ref'
    end

  end

  def blob
    @branch = current_branch
    if @branch
      @blob = @branch/(current_path.join('/'))
    end
    check_type! @blob, Grit::Blob
  end

  def raw
  end

  def current_branch
    @branch ||= extract_branch current_ref
  end

  def current_ref
    @current_ref ||= (params[:ref] == :default ? repository.manager.head : params[:ref])
  end

  def current_path
    @current_path ||= current_ref.gsub(/#{current_branch.id}[\/]?/,'').split('/')
  end

  private

  def extract_branch(tree, blob = false)
    treearr = tree.split('/').reject { |v| v.blank? or %w(. ..).include?(v) }
    treearr = treearr[0..-2] if blob

    found = false
    tree = repository.to_grit.tree
    path = []

    treearr.each_with_index do |subpath,i|
      path << subpath

      if !found
        tree = repository.to_grit.tree(path.join('/'))
      end

      begin
        check_type! tree
        found = true
        break
      rescue Error
        if (treearr.size-1) != i
          found = false
          next
        else
          tree = nil
        end
      end
    end
    tree
  end

  def check_type!(entry, type = Grit::Tree)
    raise Error, "Unknown object #{entry}" unless entry.presence.is_a?(type)
    if type == Grit::Tree
      raise Error, "Unknown object #{entry}" if entry.contents.size == 0
    end
  end

end
