require "spec_helper"

describe Repository do

  context "associations" do
    it { should belong_to :owner, :polymorphic => true }
  end

  context "validations" do
    it { should validate_presence_of :name }
  end

  describe "repository identifier" do

    it "does not allow anyone to set the identifier" do
      original_identifier = subject.identifier # Force generation
      subject.identifier = 'new-identifier'
      subject.identifier.should == original_identifier
    end

    it "generates a uuid on first access if needed" do
      subject[:identifier].should be_blank
      mock(UUID).generate { 'example-uuid' }
      subject.identifier.should == 'example-uuid'
    end

    it "doesn't regenerate the uuid if already set" do
      subject[:identifier] = 'my-example-identifier'
      dont_allow(UUID).generate
      subject.identifier.should == 'my-example-identifier'
    end

    it "should force the uuid to be generated on create" do
      subject = Repository.make
      subject[:identifier].should be_blank
      mock(UUID).generate { 'example-uuid' }
      subject.save!
      subject.identifier.should == 'example-uuid'
    end

  end

end
