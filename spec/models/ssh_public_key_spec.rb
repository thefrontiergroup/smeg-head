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

  context 'creating a key' do

    it 'should tell the key manager to record the key'

  end

  context 'destroying a key' do

    it 'should tell the key manager to remove the key'

  end

end
