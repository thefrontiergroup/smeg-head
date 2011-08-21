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
    
    context 'checking authorization permissions' do
      
      before :each do
        stub.proxy(controller).authorize!.with_any_args { |v| v }
      end
    
      it 'should check update authorization for the repository' do
        mock.proxy(controller).authorize!(:update, repository) { |v| v }
        post :create, :repository_id => repository.to_param, :user_id => repository.owner.to_param,
             :collaboration => {:user_id => collaborator.id}
      end
    
      it 'should authorize the creation of a collaborator' do
        mock.proxy(controller).authorize!(:create, is_a(Collaboration)) { |v| v }
        post :create, :repository_id => repository.to_param, :user_id => repository.owner.to_param,
             :collaboration => {:user_id => collaborator.id}
      end
      
    end
    
    it 'should correctly mark the user as a collaborator' do
      repository.should_not be_collaborator collaborator
      post :create, :repository_id => repository.to_param, :user_id => repository.owner.to_param,
           :collaboration => {:user_id => collaborator.id}
      repository.should be_collaborator collaborator
    end
    
  end
  
  describe 'the destroy action' do
    
    context 'checking authorization' do
    
      before :each do
        stub.proxy(controller).authorize!.with_any_args { |v| v }
      end
    
      it 'should check update authorization for the repository' do
        mock.proxy(controller).authorize!(:update, repository) { |v| v }
        delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      end
    
      it 'should check destroy authorization on the collaboration' do
        mock.proxy(controller).authorize!(:destroy, collaboration) { |v| v }
        delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      end
    
    end
    
    it 'should redirect on destroy' do
      delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      response.should be_redirect
      response.should redirect_to user_repository_edit_path(repository.owner.to_param, repository.to_param)
    end
    
    it 'should set the flash with a message' do
      delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      flash[:notice].should be_present
    end
    
    it 'should correctly remove the user as a collaborator' do
      collaboration # Make sure it's created in the database
      repository.should be_collaborator collaborator
      delete :destroy, :repository_id => repository.to_param, :user_id => repository.owner.to_param, :id => collaboration.id
      repository.should_not be_collaborator collaborator
    end
    
  end

end
