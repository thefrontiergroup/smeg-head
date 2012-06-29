class RepositoriesController < ApplicationController
  require 'repository_loader'
  include RepositoryLoader

  Error = Class.new(StandardError)

  helper_method :current_path

  def edit
    authorize! :update, repository
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
    begin
      @tree,@path = extract_relevant_tree current_ref
    rescue
      render 'no_ref'
    end
  end

  def blob
    @tree = extract_relevant_tree current_ref, true
    @blob = @tree / current_ref.split('/').reject { |v| v.blank? or %w(. ..).include?(v) }.last
    check_type! @blob, Grit::Blob
  end

  def raw
  end

  private

  def current_ref
    @current_ref ||= (params[:ref] == :default ? repository.manager.head : params[:ref])
  end

  def current_path
    params[:path].blank? ? [] : params[:path].split("/").reject { |v| v.blank? or %w(. ..).include?(v) }
  end

  def extract_relevant_tree(tree, blob = false)
    treearr = tree.split('/').reject { |v| v.blank? or %w(. ..).include?(v) }
    treearr = treearr[0..-2] if blob

    found = false
    tree = repository.to_grit.tree
    path = []

    treearr.each_with_index do |subpath,i|
      path << subpath
      if i == 0
        tree = tree / subpath
      end

      if !found
        Rails.logger.debug("[#{i}] nil tree #{path.join('/')}")
        tree = repository.to_grit.tree(path.join('/'))
        Rails.logger.debug("[#{i}] tree set #{tree.inspect}")
      else
        Rails.logger.debug("[#{i}] else tree")
        tree = tree / subpath
      end

      begin
        Rails.logger.debug("[#{i}] check tree #{tree.inspect} and #{path}")
        check_type! tree
        found = true
      rescue Error
        Rails.logger.debug("[#{i}] rescued")
        if (treearr.size-1) != i
          Rails.logger.debug("[#{i}] next/nil set")
          found = false
          next
        else
          Rails.logger.debug("[#{i}] raise it")
          raise "Uknown object #{path.join('/')}"
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
