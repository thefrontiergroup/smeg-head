class AddClonePathToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :clone_path, :string
    add_index :repositories, [:clone_path]
  end

  def self.down
    remove_column :repositories, :clone_path
  end
end
