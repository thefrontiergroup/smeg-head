class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :contextual_repo_path

  private

  def contextual_repo_path(context, repository, name, *args)
    options = args.extract_options!
    if options[:path].is_a?(Array)
      path = options.delete(:path)
      options[:path] = path.join("/") if path.present?
    end
    args << options
    case context
    when User
      send(:"user_repository_#{name}_path", context, repository, *args)
    else
      send(:"client_project_repository_#{name}_path", context, context.client, repository, *args)
    end
  end

end
