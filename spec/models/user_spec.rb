require 'spec_helper'

describe User do

  context 'validations' do
    it { should validate_presence_of :login }
  end

  it_should_behave_like 'a sluggable model'

  it 'should use the correct slug source' do
    subject_class.slug_source.should == :login
  end

end
