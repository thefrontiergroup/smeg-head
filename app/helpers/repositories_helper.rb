module RepositoriesHelper

  def repo_link(text, *args)
    link_to text, contextual_repo_path(*args)
  end

  def parent_path
    current_path[0..-2]
  end

  def repository_tree_path(context, repo, ref, path)
    if path.empty?
      contextual_repo_path(context, repo, :tree_root, :ref => ref)
    else
      contextual_repo_path(context, repo, :tree_child, :ref => ref, :path => path)
    end
  end

  def repository_blob_path(context, repo, ref, path)
    contextual_repo_path(context, repo, :blob, :ref => ref, :path => path)
  end

end
