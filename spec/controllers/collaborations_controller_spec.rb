require 'spec_helper'

describe CollaborationsController do
  render_views
  
  let(:repository)    { Repository.make! }
  let(:collaborator)  { User.make! }
  let(:collaboration) { Collaboration.make! :repository => repository, :user => collaborator }
  
  before(:each) { sign_in repository.owner }
  
  describe 'the create action' do
    
    it 'should render the new template with invalid data' do
      post :create, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :collaboration => {}
      response.should render_template :new
    end
    
    it 'should set the flash when successful' do
      post :create, :repository_id => repository.to_param, :user_id => repository.owner.to_param,
           :collaboration => {:user_id => collaborator.id}
      flash[:notice].should be_present
    end
    
    it 'should redirect when successful' do
      post :create, :repository_id => repository.to_param, :user_id => repository.owner.to_param,
           :collaboration => {:user_id => collaborator.id}
      response.should be_redirect
      response.should redirect_to user_repository_edit_path(repository.owner.to_param, repository.to_param)
    end
    
    it 'should check update authorization for the repository'
    
    it 'should authorize the creation of a collaborator'
    
  end
  
  describe 'the destroy action' do
    
    it 'should check update authorization for the repository'
    
    it 'should redirect on destroy' do
      delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      response.should be_redirect
      response.should redirect_to user_repository_edit_path(repository.owner.to_param, repository.to_param)
    end
    
    it 'should set the flash with a message' do
      delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      flash[:notice].should be_present
    end
    
  end

end
