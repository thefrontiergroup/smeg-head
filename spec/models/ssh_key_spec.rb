require 'spec_helper'

describe SshKey do

  context 'associations' do
    it { should belongs_to :owner, :polymorphic => true }
  end

  context 'validations' do

    it { should validate_presence_of   :name }
    it { should validate_presence_of   :owner }
    it { should validate_presence_of   :key }
    it { should validate_uniqueness_of :name, :scope => [:owner_type, :owner_id] }
    it { should validate_uniqueness_of :key }
    it { should validate_uniqueness_of :fingerprint }
    it { should validate_format_of     :key, :with => SshKey::KEY_REGEXP }

    it 'should ensure the key is a valid key format'

    it 'should ensure the key algorithm is a valid choice'

  end

  context 'setting attributes' do

    it 'should correctly normalise keys'

    it 'should require they are valid keys'

    it 'should strip out the comment'

    it 'should let you get the key algorithm'

    it 'should let you get the key contents'

  end

  context 'creating a key' do

    it 'should tell the key manager to record the key'

  end

  context 'destroying a key' do

    it 'should tell the key manager to remove the key'

  end

end
