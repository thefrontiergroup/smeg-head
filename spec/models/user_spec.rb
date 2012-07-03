require 'spec_helper'

describe User do

  context 'associations' do
    it { should have_many :repositories }
    it { should have_many :group_memberships }
    it { should have_many :groups }
    it { should have_many :ssh_public_keys }
    it { should have_many :collaborations }
    it { should have_many :collaborated_repositories }
  end

  context 'validations' do

    let!(:existing_user) { User.make! }

    it { should validate_presence_of :user_name }
    it { should validate_uniqueness_of :user_name }

    it 'should validate the user name is unchangeable' do
      user = User.make!
      user.should be_valid
      user.user_name = 'a completely new user name'
      user.should_not be_valid
      user.should have(1).errors_on(:user_name)
    end

  end

  context 'permissions' do

    let(:user_one)   { User.make! }
    let(:user_two)   { User.make! }
    let(:repository) { Repository.make! :owner => user_one }

    it 'should allow anyone to show a user' do
      user_one.should be_able_to :show, user_one
      user_two.should be_able_to :show, user_one
    end

    it 'should allow anyone to index a user' do
      user_one.should be_able_to :index, user_one
      user_two.should be_able_to :index, user_one
    end

    it 'should only allow the user to update themselves' do
      user_one.should     be_able_to :update, user_one
      user_two.should_not be_able_to :update, user_one
    end

    it 'should only allow the the user to destroy themselves' do
      user_one.should     be_able_to :destroy, user_one
      user_two.should_not be_able_to :destroy, user_one
    end

  end


  it_should_behave_like 'a sluggable model'

  it 'should use the correct slug source' do
    subject_class.slug_source.should == :user_name
  end

  describe 'generating a path prefix' do

    it 'should use the slug value' do
      user = User.make!
      user.path_prefix.should == user.to_slug
    end

  end

end
