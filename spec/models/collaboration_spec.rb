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
    
    context 'user name validation' do
    
      subject { Collaboration.last }
    
      it 'should not add an error to the user name field when assigning directly' do
        user = subject.user
        subject.should be_valid
        subject.user = nil
        subject.should_not be_valid
        subject.should_not have(:any).errors_on(:user_name)
      end
    
      it 'should add an error to the user name field if the user is unknown and assigned via user name' do
        user = subject.user
        subject.user_name = 'Some Fake Test Name'
        subject.should_not be_valid
        subject.should have(1).errors_on(:user_name)
        subject.user_name = user.user_name
        subject.should be_valid
      end
    
    end
    
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
    
    it 'should store the user name on invalid assignments' do
      collaboration.user_name = 'some-invalid-user-name'
      collaboration.user_name.should == 'some-invalid-user-name'
      collaboration.user.should be_blank
    end
    
  end

end
