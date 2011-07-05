require 'spec_helper'

describe Collaboration do

  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :repository }
  end

  context 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :repository  }
  end

end
