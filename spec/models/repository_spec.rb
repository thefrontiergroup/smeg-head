require 'spec_helper'

describe Repository do

  context 'associations' do
    it { should belong_to :owner, :polymorphic => true }
  end

  context 'validations' do
    it { should validate_presence_of :owner }
  end

end
