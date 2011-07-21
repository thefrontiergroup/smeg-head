require 'spec_helper'

describe Collaboration do

  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :repository }
  end

  context 'validations' do
    
    before(:each) { Collaboration.make! }
    
    it { should validate_presence_of :user }
    it { should validate_presence_of :repository  }
    it { should validate_uniqueness_of :user_id, :scope => :repository_id }
  end
  
  describe 'setting based on the user name' do
    
    let(:collaboration) { Collaboration.make! }
    
    it 'should let you get the users name' do
      collaboration.user.user_name = 'TestUser'
      collaboration.user_name.should == 'TestUser'
    end
    
    it 'should return nil without a user' do
      collaboration.user = nil
      collaboration.user_name.should be_nil
    end
    
    it 'should let you set the user from a name' do
      collaboration.user = nil
      user = User.make!
      collaboration.user_name = user.user_name
      collaboration.user.should == user
    end
    
    it 'should let you blank values' do
      collaboration.user_name = nil
      collaboration.user.should be_nil
      collaboration.user_name = ''
      collaboration.user.should be_nil
    end
    
  end

end
