require 'spec_helper'

describe Group do

  context 'associations' do
    it { should have_many :memberships, :class_name => 'GroupMembership' }
    it { should have_many :users, :through => :memberships }
  end

  context 'validations' do
  end

  it_should_behave_like 'a sluggable model'

end
