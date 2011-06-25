require 'spec_helper'

describe SmegHead::RefChange do

  let(:example_ref_a) { ActiveSupport::SecureRandom.hex 20 }
  let(:example_ref_b) { ActiveSupport::SecureRandom.hex 20 }
  let(:example_name)  { 'refs/heads/my-test-ref' }

  describe 'checking the state of refs' do

    it 'should correctly detect created refs' do
      ref_change = SmegHead::RefChange.new(SmegHead::RefChange::NONEXISTANT_REF, example_ref_a, example_name)
      ref_change.should be_created
      ref_change.should_not be_changed
      ref_change.should_not be_deleted
    end

    it 'should correctly detect deleted refs' do
      ref_change = SmegHead::RefChange.new(example_ref_a, SmegHead::RefChange::NONEXISTANT_REF, example_name)
      ref_change.should be_deleted
      ref_change.should_not be_created
      ref_change.should_not be_changed
    end

    it 'should correctly detect changed refs' do
      ref_change = SmegHead::RefChange.new(example_ref_a, example_ref_b, example_name)
      ref_change.should be_changed
      ref_change.should_not be_created
      ref_change.should_not be_deleted
    end

  end

  describe 'getting data values' do

    let(:ref_change) { SmegHead::RefChange.new(example_ref_a, example_ref_b, example_name) }

    it 'should let you get the new ref hash' do
      ref_change.new_ref.should == example_ref_b
    end

    it 'should let you get the old ref hash' do
      ref_change.old_ref.should == example_ref_a
    end

    it 'should let you get the full ref name' do
      ref_change.full_ref_name.should == example_name
    end

    it 'should let you get a processed ref reference' do
      ref = ref_change.ref
      ref.should be_a SmegHead::Ref
      ref.full.should == example_name
    end

  end

end