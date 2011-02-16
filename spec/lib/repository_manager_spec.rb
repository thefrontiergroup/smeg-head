require 'spec_helper'

describe RepositoryManager do
  
  it 'should have a sane default base path'
  
  it 'require an argument'
  
  it 'should have a repository'
  
  describe 'with a repository' do
  
    let(:repository) { Repository.new(:name => 'Bobs Repository Of Doom') }
    let(:manager)    { RepositoryManager.new(repository) }
  
    it 'should let you get a repository path' do
      manager.should respond_to(:path)
      path = manager.path
      path.should be_a(Pathname)
      path.to_s.start_with?(RepositoryManager.base_path.to_s).should be_true
      path.to_s.should include(repository.identifier)
      path.extname.should == '.git'
    end
  
    it 'should let you create the repository' do
      manager.path.exist?.should be_false
      manager.create!
      manager.path.exist?.should be_true
      manager.path.join('refs').exist?.should be_true
    end
  
    it 'should let you remove the repository' do
      manager.create!
      manager.path.exist?.should be_true
      
      
    end
  
    it 'should raise an exception when destroying an non-existant repository'
  
    it 'should let you run a block inside a directory'
  
  end
  
end
