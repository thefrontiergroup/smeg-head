class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.string :description
      t.string :cached_slug
      t.timestamps
    end
    add_index :groups, [:cached_slug]
  end

  def self.down
    drop_table :groups
  end
end
