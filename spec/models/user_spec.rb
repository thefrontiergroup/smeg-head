require 'spec_helper'

describe User do

  context 'validations' do
    it { should validate_presence_of :login }
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
