require 'spec_helper'

describe User do

  context 'associations' do
    it { should have_many :repositories, :as => :owner }
    it { should have_many :group_memberships }
    it { should have_many :groups, :through => :group_memberships }
  end

  context 'validations' do

    let!(:existing_user) { User.make! }

    it { should validate_presence_of :login }
    it { should validate_uniqueness_of :login }

    it 'should validate the login is unchangeable' do
      user = User.make!
      user.should be_valid
      user.login = 'a completely new login'
      user.should_not be_valid
      user.should have(1).errors_on(:login)
    end

  end

  it_should_behave_like 'a sluggable model'

  it 'should use the correct slug source' do
    subject_class.slug_source.should == :login
  end

  describe 'generating a path prefix' do

    it 'should use the slug value' do
      user = User.make!
      user.path_prefix.should == user.to_slug
    end

  end

end
