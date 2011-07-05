require "spec_helper"

describe Repository do

  context "associations" do
    it { should belong_to :owner, :polymorphic => true }
  end

  context "validations" do
    it { should validate_presence_of :name, :owner }
    it { should validate_inclusion_of :publically_accessible, :in => [true, false] }
  end

  context 'permissions' do

    let(:user_one)   { User.make! }
    let(:user_two)   { User.make! }
    let(:user_three)   { User.make! }
    let(:repository) { Repository.make! :owner => user_one }

    before :each do
      stub(repository).administrator?(user_one)   { true }
      stub(repository).administrator?(user_two)   { false }
      stub(repository).administrator?(user_three) { false }
      stub(repository).member?(user_one)          { true }
      stub(repository).member?(user_two)          { true }
      stub(repository).member?(user_three)        { false }
    end

    it 'should allow anyone to create a repository' do
      user_one.should be_able_to :create, Repository
      user_two.should be_able_to :create, Repository
      user_three.should be_able_to :create, Repository
    end

    it 'should only allow the administrators to update a repository' do
      user_one.should       be_able_to :update, repository
      user_two.should_not   be_able_to :update, repository
      user_three.should_not be_able_to :update, repository
    end

    it 'should only allow administrators to destroy a repository' do
      user_one.should       be_able_to :destroy, repository
      user_two.should_not   be_able_to :destroy, repository
      user_three.should_not be_able_to :destroy, repository
    end

    describe 'public repositories' do

      before :each do
        repository.update_attribute :publically_accessible, true
      end

      it 'should allow anyone to show a repository' do
        user_one.should   be_able_to :show, repository
        user_two.should   be_able_to :show, repository
        user_three.should be_able_to :show, repository
      end

      it 'should allow anyone to index a repository' do
        user_one.should   be_able_to :index, repository
        user_two.should   be_able_to :index, repository
        user_three.should be_able_to :index, repository
      end

    end

    describe 'private repositories' do

      before :each do
        repository.update_attribute :publically_accessible, false
      end

      it 'should allow members to show a repository' do
        user_one.should       be_able_to :show, repository
        user_two.should       be_able_to :show, repository
        user_three.should_not be_able_to :show, repository
      end

      it 'should allow members to index the repository' do
        user_one.should       be_able_to :index, repository
        user_two.should       be_able_to :index, repository
        user_three.should_not be_able_to :index, repository
      end

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

    describe 'repository permissions checks' do

      let(:user)             { User.make! }
      let(:other_user)       { User.make! }
      let(:public_key)       { SshPublicKey.make :owner => user }
      let(:other_public_key) { SshPublicKey.make :owner => other_user }
      let(:repository)       { Repository.make! }
      let(:ability)          { Ability.new(user) }
      let(:other_ability)    { Ability.new(other_user) }

      before :each do
        stub(user).ability       { ability }
        stub(other_user).ability { other_ability }
      end

      describe 'readable by' do

        it 'should use the ability check when logged as a user' do
          mock(ability).can?(:read, repository) { true }
          repository.readable_by?(public_key)
        end

        it 'should return the correct value dependent on the ability' do
          stub(ability).can?(:read, repository) { true }
          stub(other_ability).can?(:read, repository) { false }
          repository.should be_readable_by public_key
          repository.should_not be_readable_by other_public_key
          repository.should be_readable_by user
          repository.should_not be_readable_by other_user
        end

      end

      describe 'writeable by' do

        it 'should use the ability check when logged as a user' do
          mock(ability).can?(:update, repository) { true }
          repository.writeable_by?(public_key)
        end

        it 'should only allow members to write to a repository' do
          stub(repository).member?(user)       { true }
          stub(repository).member?(other_user) { false }
          # Actual permissions checks
          repository.should     be_writeable_by public_key
          repository.should_not be_writeable_by other_public_key
          repository.should     be_writeable_by user
          repository.should_not be_writeable_by other_user
        end

      end

    end

  end

end
