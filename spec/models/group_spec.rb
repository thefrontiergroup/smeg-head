require 'spec_helper'

describe Group do

  context 'associations' do
    it { should have_many :memberships }
    it { should have_many :users }
  end

  context 'validations' do
  end

  it_should_behave_like 'a sluggable model'

end
