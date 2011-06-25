class Users::SshPublicKeysController < ApplicationController

   before_filter :authenticate_user!

  inherit_resources

  actions :create, :edit, :update, :destroy

  respond_to :html, :json

  def create
    create!(:notice => "Key successfully created.") { edit_user_registration_path }
  end

  def update
    update!(:notice => "Key successfully updated.") { edit_user_registration_path }
  end

  def destroy
    destroy!(:notice => "Key successfully removed.") { edit_user_registration_path }
  end

  protected

  def end_of_association_chain
    current_user.ssh_public_keys
  end

end
