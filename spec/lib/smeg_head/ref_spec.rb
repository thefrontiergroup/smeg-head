require 'spec_helper'

describe SmegHead::Ref do

  describe 'creating a ref' do

    it 'should correctly set the full output of the given ref' do
      SmegHead::Ref.new('refs/heads/develop').full.should == 'refs/heads/develop'
    end

    it 'should correctly break the ref into parts' do
      SmegHead::Ref.new('refs/heads/develop').parts.should == %w(refs heads develop)
      SmegHead::Ref.new('refs/heads/tfg/develop').parts.should == %w(refs heads tfg/develop)
    end

    it 'should set the type key field' do
      SmegHead::Ref.new('refs/heads/develop').type_key.should == :heads
      SmegHead::Ref.new('refs/remotes/develop').type_key.should == :remotes
    end

    it 'should set the name field of the ref' do
      SmegHead::Ref.new('refs/heads/develop').name.should == 'develop'
      SmegHead::Ref.new('refs/heads/tfg/develop').name.should == 'tfg/develop'
    end

  end

  describe 'getting the refs name' do

    it 'should correctly deal with simple names' do
      SmegHead::Ref.new('refs/heads/develop').name.should == 'develop'
      SmegHead::Ref.new('refs/heads/master').name.should  == 'master'
    end

    it 'should correctly deal with names with multiple slashes' do
      SmegHead::Ref.new('refs/heads/release/1.0.0').name.should             == 'release/1.0.0'
      SmegHead::Ref.new('refs/heads/hotfix/oh-god-the-burning').name.should == 'hotfix/oh-god-the-burning'
      SmegHead::Ref.new('refs/heads/down/the/rabbit/hole').name.should      == 'down/the/rabbit/hole'
    end

    it 'should provide a tag name alias' do
      ref = SmegHead::Ref.new('refs/tags/1.0.0')
      ref.name.should == ref.tag_name
    end

    it 'should provide a branch name alias' do
      ref = SmegHead::Ref.new('refs/heads/develop')
      ref.name.should == ref.branch_name
    end

    it 'should provide a remote name alias' do
      ref = SmegHead::Ref.new('refs/remotes/origin/develop')
      ref.name.should == ref.remote_name
    end

  end

  describe 'getting the type of a given ref' do

    it 'should correctly detect tags' do
      ref = SmegHead::Ref.new('refs/tags/my-tag')
      ref.type.should == :tag
      ref.should be_tag
      ref.should_not be_branch
      ref.should_not be_remote
      ref.should_not be_note
      ref.should_not be_unknown
    end

    it 'should correctly detect branches' do
      ref = SmegHead::Ref.new('refs/heads/develop')
      ref.type.should == :branch
      ref.should_not be_tag
      ref.should be_branch
      ref.should_not be_remote
      ref.should_not be_note
      ref.should_not be_unknown
    end

    it 'should correctly detect remotes' do
      ref = SmegHead::Ref.new('refs/remotes/origin/master')
      ref.type.should == :remote
      ref.should_not be_tag
      ref.should_not be_branch
      ref.should be_remote
      ref.should_not be_note
      ref.should_not be_unknown
    end

    it 'should correctly detect notes' do
      ref = SmegHead::Ref.new('refs/notes/ninja-time')
      ref.type.should == :note
      ref.should_not be_tag
      ref.should_not be_branch
      ref.should_not be_remote
      ref.should be_note
      ref.should_not be_unknown
    end

    it 'should return unknown for an unknown ref type' do
      ref = SmegHead::Ref.new('refs/something-else/entierly')
      ref.type.should == :unknown
      ref.should_not be_tag
      ref.should_not be_branch
      ref.should_not be_remote
      ref.should_not be_note
      ref.should be_unknown
    end

  end

end
