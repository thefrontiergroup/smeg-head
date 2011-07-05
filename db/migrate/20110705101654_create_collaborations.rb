class CreateCollaborations < ActiveRecord::Migration
  def self.up
    create_table :collaborations do |t|
      t.belongs_to :repository
      t.belongs_to :user
      t.timestamps
    end
    add_index :collaborations, [:repository_id, :user_id]
  end

  def self.down
    drop_table :collaborations
  end
end
