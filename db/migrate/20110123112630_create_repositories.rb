class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name, :null => false
      t.text   :description
      t.string :identifier, :null => false, :unique => true
      t.string :cached_slug, :null => false
      t.belongs_to :owner, :polymorphic => true
      t.timestamps
    end
    add_index :repositories, [:owner_type, :owner_id, :cached_slug]
  end

  def self.down
    drop_table :repositories
  end
end
