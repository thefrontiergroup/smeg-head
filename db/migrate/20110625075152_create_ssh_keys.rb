class CreateSshKeys < ActiveRecord::Migration
  def self.up
    create_table :ssh_keys do |t|
      t.belongs_to :owner, :polymorphic => true, :null => false
      t.string :name, :null => false
      t.string :fingerprint, :null => false
      t.text :key, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :ssh_keys
  end
end
