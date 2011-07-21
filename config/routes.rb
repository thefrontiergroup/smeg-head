SmegHead::Application.routes.draw do

  repository_routes = proc do
    with_scope_level :resources do
      nested do
        scope ':repository_id', :as => :repository do
          resources :collaborations
          get    '/',               :as => :root,       :to => 'repositories#tree', :ref => :default
          put    '/',               :as => :update,     :to => 'repositories#update'
          delete '/',               :as => :destroy,    :to => 'repositories#destroy'
          get    'edit',            :as => :edit,       :to => 'repositories#edit'
          get    'commits/:ref',    :as => :commits,    :to => 'repositories#commits'
          get    'commit/:ref',     :as => :commit,     :to => 'repositories#commit'
          get    'tree/:ref/*path', :as => :tree_child, :to => 'repositories#tree'
          get    'tree/:ref',       :as => :tree_root,  :to => 'repositories#tree'
          get    'blob/:ref/*path', :as => :blob,       :to => 'repositories#blob'
          get    'raw/:ref/*path',  :as => :raw,        :to => 'repositories#raw'
        end
      end
    end
  end

  namespace :users do
    resources :ssh_public_keys
    resources :repositories, :only => [:new, :create]
  end

  devise_for :users

  authenticated :user do
    root :to => 'site#dashboard'
  end

  root :to => 'site#index'

  resources :users, :only => [:show], &repository_routes
  #
  # resources :clients do
  #   resources :projects, &repository_routes
  # end

end
