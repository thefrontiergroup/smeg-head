class AddLoginToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :login, :string
    add_column :users, :cached_slug, :string
    add_index :users, [:cached_slug]
  end

  def self.down
    remove_column :users, :cached_slug
    remove_column :users, :login
  end
end
