require 'spec_helper'

describe GroupMembership do

  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :group }
  end

  context 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :group }
  end


end
