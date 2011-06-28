require 'spec_helper'
require 'authorized_keys_file'
require 'tempfile'

describe AuthorizedKeysFile do

  let(:temporary_path)  { Tempfile.new('authorized_keys').tap(&:close).path }
  let(:auth_keys_file)  { AuthorizedKeysFile.new temporary_path }
  let(:example_key)     { ExampleKeys.good_dsa }
  let(:example_key_two) { ExampleKeys.good_rsa }

  describe 'adding a key' do

    it 'should let you add a key to a file' do
      File.readlines(temporary_path).should be_empty
      auth_keys_file.add example_key
      lines = File.readlines(temporary_path)
      lines.should have(1).lines
      lines.detect { |i| i.include? example_key }.should be_present
    end

    it 'should let you add options' do
      auth_keys_file.add example_key, :is_awesome => true, :ninjas => false, :name => 'test'
      lines = File.readlines(temporary_path)
      line = lines.detect { |i| i.include? example_key }
      items = line.split(" ", 2).first.split(",")
      items.should be_present
      items.should include "is-awesome"
      items.should include "no-ninjas"
      items.should include "name=\"test\""
    end

  end

  describe 'removing a key' do

    before :each do
      auth_keys_file.add example_key
      auth_keys_file.add example_key_two
    end

    it 'should not leave a blank line' do
      File.readlines(temporary_path).should have(2).lines
      auth_keys_file.remove example_key
      File.readlines(temporary_path).should have(1).lines
      auth_keys_file.remove example_key_two
      File.readlines(temporary_path).should have(:no).lines
    end

    it 'should remove the given key from the file' do
      auth_keys_file.remove example_key
      File.read(temporary_path).should_not include example_key
    end

    it 'should do nothing without invalid content' do
      original = File.read(temporary_path)
      auth_keys_file.remove "ssh-blah some-random-non-existant-key"
      File.read(temporary_path).should == original
    end

  end

  describe 'checking for the existance of a key' do

    before :each do
      auth_keys_file.add example_key
    end

    it 'should correctly reflect existing keys' do
      auth_keys_file.should have_key example_key
      auth_keys_file.should_not have_key example_key_two
    end

    it 'should correctly reflect keys that have been added' do
      auth_keys_file.add example_key_two
      auth_keys_file.should have_key example_key
      auth_keys_file.should have_key example_key_two
    end

    it 'should correctly reflect keys that have been removed' do
      auth_keys_file.remove example_key
      auth_keys_file.should_not have_key example_key
      auth_keys_file.should_not have_key example_key_two
    end

  end

end
