require 'spec_helper'

describe Users::RepositoriesController do

  render_views

  let!(:user)   { User.make! }
  before(:each) { sign_in user }

  describe 'the create action' do

    it 'should set the flash after create' do
      post :create, :repository => {:name => 'Test Name'}
      flash[:notice].should be_present
    end

    it 'should redirect to the correct place' do
      post :create, :repository => {:name => 'Test Name'}
      response.should be_redirect
      response.should redirect_to user_repository_root_path(:user_id => user, :repository_id => 'test-name')
    end

    it 'should render the new template without valid data' do
      post :create, :repository => {:name => ''}
      response.should render_template :new
    end

  end


end
