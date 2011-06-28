require 'spec_helper'

require 'smeg_head/shell'
require 'smeg_head/shell/command'

describe SmegHead::Shell::Command do

  let(:upload_a)  { SmegHead::Shell::Command.parse 'git upload-pack a' }
  let(:upload_b)  { SmegHead::Shell::Command.parse 'git-upload-pack b' }
  let(:receive_a) { SmegHead::Shell::Command.parse 'git receive-pack c' }
  let(:receive_b) { SmegHead::Shell::Command.parse 'git-receive-pack d' }

  describe 'extracting parts of the command' do

    let(:complex) { SmegHead::Shell::Command.parse('git upload-pack "my test repository of doom"') }

    it 'should split the parts correctly' do
      upload_a.parts.should == ['git-upload-pack', 'a']
      complex.parts.should  == ['git-upload-pack', 'my test repository of doom']
    end

    it 'should correctly detect the identifier part' do
      complex.identifier.should   == 'my test repository of doom'
      upload_a.identifier.should  == 'a'
      receive_b.identifier.should == 'd'
    end

    it 'should correctly detect the command part' do
      complex.command.should == 'git-upload-pack'
      upload_a.command.should == 'git-upload-pack'
      receive_b.command.should == 'git-receive-pack'
    end

    it 'should correctly detect the verb' do
      upload_a.verb.should == :read
      upload_b.verb.should == :read
      receive_a.verb.should == :write
      receive_b.verb.should == :write
    end

  end

  describe 'verb checking' do

    it 'should correctly detect read commands' do
      upload_a.should be_read
      upload_b.should be_read
      receive_a.should_not be_read
      receive_b.should_not be_read
    end

    it 'should correctly detect write commands' do
      upload_a.should_not be_write
      upload_b.should_not be_write
      receive_a.should be_write
      receive_b.should be_write
    end

  end

  describe 'error checking' do

    it 'should throw an exception with missing commands' do
      expect { SmegHead::Shell::Command.parse('') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('  ') }.to raise_error SmegHead::Shell::Error
    end

    it 'should throw an exception with invalid commands / verbs' do
      expect { SmegHead::Shell::Command.parse('a b') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('another-command a') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('git wtf a') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('git-wtf a') }.to raise_error SmegHead::Shell::Error

    end

    it 'should throw an exception without a repository part' do
      expect { SmegHead::Shell::Command.parse('git-upload-pack') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('git upload-pack') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('git-receive-pack') }.to raise_error SmegHead::Shell::Error
      expect { SmegHead::Shell::Command.parse('git receive-pack') }.to raise_error SmegHead::Shell::Error
    end

  end

end
