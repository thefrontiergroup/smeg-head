module RepositoryLoader
  extend ActiveSupport::Concern
  
  included do
    before_filter :prepare_owner
    before_filter :prepare_repository
    attr_reader   :owner, :repository
    helper_method :owner, :repository
  end
  
  module InstanceMethods
    
    private    
    
    def prepare_owner
      source = request.path_parameters.with_indifferent_access
      if source[:user_id].present?
        @owner = @user = User.find_using_slug!(source[:user_id])
      else # Fallback to other
        raise ActiveRecord::RecordNotFound
      end
    end

    def prepare_repository
      @repository = owner.repositories.find_using_slug!(params[:repository_id])
    end
    
  end
end