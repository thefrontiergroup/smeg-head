require 'spec_helper'

describe Users::SshPublicKeysController do

  render_views

  let!(:user)      { User.make! }
  let(:public_key) { SshPublicKey.make! :owner => user }
  before(:each)    { sign_in user }

  describe 'the create action' do

    it 'should set the flash after create' do
      post :create, :ssh_public_key => {:name => 'Test Name', :key => ExampleKeys.good_rsa }
      flash[:notice].should be_present
    end

    it 'should redirect to the correct place' do
      post :create, :ssh_public_key => {:name => 'Test Name', :key => ExampleKeys.good_rsa }
      response.should be_redirect
      response.should redirect_to edit_user_registration_path
    end

    it 'should render the new template without valid data' do
      post :create, :ssh_public_key => {:name => 'Test Name', :key => ExampleKeys.bad_rsa }
      response.should render_template :new
    end

  end

  describe 'the update action' do

    it 'should set the flash after update' do
      put :update, :id => public_key.id, :ssh_public_key => {:name => 'New Key Name'}
      flash[:notice].should be_present
    end

    it 'should redirect to the correct place' do
      put :update, :id => public_key.id, :ssh_public_key => {:name => 'New Key Name'}
      response.should be_redirect
      response.should redirect_to edit_user_registration_path
    end

    it 'should render the edit template without valid data' do
      put :update, :id => public_key.id, :ssh_public_key => {:name => ''}
      response.should render_template :edit
    end

  end

  describe 'the destroy action' do

    it 'should set the flash after destroy' do
      delete :destroy, :id => public_key.id
      flash[:notice].should be_present
    end

    it 'should redirect to the correct place' do
      delete :destroy, :id => public_key.id
      response.should be_redirect
      response.should redirect_to edit_user_registration_path
    end

  end


end
