require "spec_helper"

describe Repository do

  context "associations" do
    it { should belong_to :owner, :polymorphic => true }
  end

  context "validations" do
    it { should validate_presence_of :name, :owner }
  end

  context 'permissions' do

    let(:user_one)   { User.make! }
    let(:user_two)   { User.make! }
    let(:repository) { Repository.make! :owner => user_one }

    it 'should allow anyone to create a repository' do
      user_one.should be_able_to :create, Repository
      user_two.should be_able_to :create, Repository
    end

    it 'should allow anyone to show a repository' do
      user_one.should be_able_to :show, repository
      user_two.should be_able_to :show, repository
    end

    it 'should allow anyone to index a repository' do
      user_one.should be_able_to :index, repository
      user_two.should be_able_to :index, repository
    end

    it 'should only allow the owner to update a repository' do
      user_one.should     be_able_to :update, repository
      user_two.should_not be_able_to :update, repository
    end

    it 'should only allow the owner to destroy a repository' do
      user_one.should     be_able_to :destroy, repository
      user_two.should_not be_able_to :destroy, repository
    end

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

  it_should_behave_like 'a sluggable model'

  it 'should use the correct slug source' do
    subject_class.slug_source.should == :name
  end

  describe 'the calculated clone path' do

    let(:user)       { User.make! :user_name => 'Archibald' }
    let(:repository) { Repository.make! :owner => user, :name => 'Ninja Skulls of Doom' }

    it 'should calculate the correct value' do
      repository.calculated_clone_path.should == "#{user.to_param}/#{repository.to_param}"
    end

    it 'should change when we update the owner' do
      pending
      expect do
        repository.owner.update_attributes! :user_name => Forgery(:internet).user_name
      end.to change(repository, :calculated_clone_path)
    end

  end

  describe 'the clone path' do

    let(:repository) { Repository.make! }

    it 'should use the attribute if present' do
      repository[:clone_path] = 'my-stored-clone-path'
      repository.clone_path.should == 'my-stored-clone-path'
    end

    it 'should calculate a value when the real value is missing' do
      mock(repository).calculated_clone_path { 'my-calculated-clone-path' }
      repository[:clone_path] = nil
      repository.clone_path.should == 'my-calculated-clone-path'
    end

    it 'should cache it on save' do
      repository = Repository.make
      repository[:clone_path].should be_blank
      repository.save!
      repository[:clone_path].should be_present
    end

  end

  describe 'normalising a repository path' do

    it 'should return nil for blank values' do
      Repository.normalize_path(' ').should == nil
      Repository.normalize_path('').should == nil
      Repository.normalize_path('.git').should == nil
      Repository.normalize_path('...git').should == nil
    end

    it 'should expand double dots' do
      Repository.normalize_path('x/y/../z').should == 'x/z'
      Repository.normalize_path('../a.git').should == 'a'
      Repository.normalize_path('a/...git').should == nil
    end

    it 'should remove trailing gits' do
      Repository.normalize_path('a.git').should == 'a'
      Repository.normalize_path('a/b.git').should == 'a/b'
    end

    it 'should remove multiple slashes' do
      Repository.normalize_path('a//b').should == 'a/b'
    end

  end

end
