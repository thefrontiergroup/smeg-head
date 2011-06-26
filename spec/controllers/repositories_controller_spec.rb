require 'spec_helper'

describe RepositoriesController do

  render_views

  let(:owner)       { User.make! }
  let(:other_user)  { User.make! }
  let!(:repository) { Repository.make! :owner => owner }

  before(:each)    { sign_in owner }

  describe 'editing a repository' do

    it 'should not allow other users to edit the repository' do
      sign_in other_user
      expect do
        get :edit, :repository_id => repository.to_param, :user_id => owner.to_param
      end.to raise_error(CanCan::AccessDenied)
    end

    it 'should render the correct template' do
      get :edit, :repository_id => repository.to_param, :user_id => owner.to_param
      response.should render_template :edit
    end

    it 'should be success' do
      get :edit, :repository_id => repository.to_param, :user_id => owner.to_param
      response.should be_successful
    end

  end

  describe 'updating a repository' do

    it 'should not allow other users to update the repository' do
      sign_in other_user
      expect do
        put :update, :repository_id => repository.to_param, :user_id => owner.to_param
      end.to raise_error(CanCan::AccessDenied)
    end

    context 'a successful update' do

      before(:each) { put :update, :repository_id => repository.to_param, :user_id => owner.to_param, :repository => {:description => 'Insert String Here'} }

      it 'should update the object' do
        repository.reload
        repository.description.should == 'Insert String Here'
      end

      it 'should correctly redirect' do
        response.should be_redirect
        response.should redirect_to user_repository_root_path(owner, repository)
      end

    end

    context 'an unsuccessful update' do

      before(:each) { put :update, :repository_id => repository.to_param, :user_id => owner.to_param, :repository => {:name => ''} }

      it 'should not redirect' do
        response.should_not be_redirect
      end

      it 'should not have updated the object' do
        original_name = repository.name
        repository.reload
        repository.name.should == original_name
      end

      it 'should rerender the edit page' do
        response.should render_template(:edit)
      end

    end

  end

  describe 'destroying a repository' do

    it 'should not allow other users to destroy the repository' do
      sign_in other_user
      expect do
        delete :destroy, :repository_id => repository.to_param, :user_id => owner.to_param
      end.to raise_error(CanCan::AccessDenied)
    end

    it 'should remove the repository' do
      delete :destroy, :repository_id => repository.to_param, :user_id => owner.to_param
      Repository.where(:id => repository.id).should be_empty
    end

    it 'should redirect to the home page' do
      delete :destroy, :repository_id => repository.to_param, :user_id => owner.to_param
      response.should redirect_to :root
    end

  end

end
