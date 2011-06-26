class AddUserNameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :user_name, :string
    add_column :users, :cached_slug, :string
    add_index :users, [:cached_slug]
    add_index :users, [:user_name], :unique => true
  end

  def self.down
    remove_column :users, :cached_slug
    remove_column :users, :user_name
  end
end
