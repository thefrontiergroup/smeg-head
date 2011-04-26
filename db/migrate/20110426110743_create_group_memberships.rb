class CreateGroupMemberships < ActiveRecord::Migration
  def self.up
    create_table :group_memberships do |t|
      t.belongs_to :group
      t.belongs_to :user
      t.boolean    :administrator, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :group_memberships
  end
end
