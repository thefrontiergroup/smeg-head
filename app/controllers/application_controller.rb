require 'polymorphic_resource_mixin'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include PolymorphicResourceMixin

end
