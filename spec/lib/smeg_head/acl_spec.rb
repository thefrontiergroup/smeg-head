require 'spec_helper'
require 'smeg_head/acl'

describe SmegHead::ACL do

  it 'should let you parse an ACL entry' do
    expect do
      SmegHead::ACL.parse 'allow all from collaborators to refs *'
    end.to_not raise_error
  end

  it 'should raise parsing errors when encountered' do
    expect {SmegHead::ACL.parse('') }.to raise_error SmegHead::ACL::Error
    expect { SmegHead::ACL.parse('blah from blah') }.to raise_error SmegHead::ACL::Error
    expect { SmegHead::ACL.parse('fsdfs') }.to raise_error SmegHead::ACL::Error
  end

  it 'should return a permission list' do
    parsed = SmegHead::ACL.parse 'allow all from collaborators to refs *'
    parsed.should be_a SmegHead::ACL::PermissionList
  end

end