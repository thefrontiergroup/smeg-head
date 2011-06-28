require 'spec_helper'

describe SshPublicKey do

  context 'associations' do
    it { should belong_to :owner, :polymorphic => true }
  end

  context 'validations' do

    let!(:existing_key) { SshPublicKey.make! }
    let(:new_key)       { SshPublicKey.new }

    it { should validate_presence_of   :name }
    it { should validate_presence_of   :owner }
    it { should validate_presence_of   :key }
    it { should validate_presence_of   :fingerprint }
    it { should validate_uniqueness_of :name, :scope => [:owner_type, :owner_id] }
    it { should validate_uniqueness_of :key }
    it { should validate_uniqueness_of :fingerprint }

    it { should     allow_values_for :key, *ExampleKeys.known_good_keys }
    it { should_not allow_values_for :key, *ExampleKeys.known_bad_keys  }

  end

  context 'setting attributes' do

    let(:key) { SshPublicKey.new }

    it 'should correctly convert blank values' do
      key.key = ''
      key.key.should be_nil
      key.key = '   '
      key.key.should be_nil
    end

    it 'should strip out the comment' do
      key.key = 'ssh-dss testkeycontentsgohere comment-goes-here'
      key.key.should == 'ssh-dss testkeycontentsgohere'
      key.key = 'ssh-dss testkeycontentsgohere this is a multipart comment'
      key.key.should == 'ssh-dss testkeycontentsgohere'
    end

    it 'should let you get the key algorithm' do
      key.key = 'ssh-dss testkeycontentsgohere'
      key.algorithm.should == :dsa
      key.key = 'ssh-rsa testkeycontentsgohere'
      key.algorithm.should == :rsa
      key.key = 'ssh-abc testkeycontentsgohere'
      key.algorithm.should == :unknown
    end

    it 'should let you get the key contents' do
      key.key = 'ssh-dss testkeycontentsgohere'
      key.key_content.should == 'testkeycontentsgohere'
      key.key = 'ssh-rsa testkeycontentsgohere'
      key.key_content.should == 'testkeycontentsgohere'
    end

    it 'should correctly normalise badly formatted keys' do
      key.key = '    ssh-rsa testkeycontentsgohere   '
      key.key.should == 'ssh-rsa testkeycontentsgohere'
      key.key = "ssh-rsa testk\neycontent\nsgohere"
      key.key.should == 'ssh-rsa testkeycontentsgohere'
    end

  end

  context 'permissions' do

    let(:user_one)   { User.make! }
    let(:user_two)   { User.make! }
    let(:public_key) { SshPublicKey.make! :owner => user_one }

    it 'should let you anyone make public keys' do
      user_one.should be_able_to :create, SshPublicKey
      user_two.should be_able_to :create, SshPublicKey
    end

    it 'should only allow the owner to update the public key' do
      user_one.should     be_able_to :update, public_key
      user_two.should_not be_able_to :update, public_key
    end

    it 'should only allow the owner to remove the public key' do
      user_one.should     be_able_to :destroy, public_key
      user_two.should_not be_able_to :destroy, public_key
    end

    it 'should only allow the owner to show the public key' do
      user_one.should     be_able_to :show, public_key
      user_two.should_not be_able_to :show, public_key
    end

    it 'should only allow the owner to index the public key' do
      user_one.should     be_able_to :index, public_key
      user_two.should_not be_able_to :index, public_key
    end

  end

  context 'managing the key file' do

    around(:each) do |block|
      ExampleKeys.with_mock_authorized_keys &block
    end

    let(:public_key) { SshPublicKey.make }

    it 'should record the key when it is created' do
      current_key_lines.should be_empty
      public_key.save
      current_key_lines.should have(1).line
      current_key_lines.first.should include public_key.key
    end

    it 'should remove the key when it is destroyed' do
      public_key.save
      current_key_lines.should have(1).line
      public_key.destroy
      current_key_lines.should have(:no).line
    end

    it 'should tell the key manager to update the key when it is changed' do
      public_key.save
      original_lines = current_key_lines
      original_lines.should have(1).line
      public_key.update_attributes :key => ExampleKeys.good_dsa
      new_lines = current_key_lines
      new_lines.should have(1).line
      new_lines.should_not == original_lines
      new_lines.first.should include ExampleKeys.good_dsa
    end

    private

    def current_key_lines
      File.readlines SshPublicKeyManager.authorized_keys_path
    end

  end

end
