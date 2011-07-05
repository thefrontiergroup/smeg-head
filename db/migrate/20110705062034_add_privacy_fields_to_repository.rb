class AddPrivacyFieldsToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :publically_accessible, :boolean, :default => true
  end

  def self.down
    remove_column :repositories, :publically_accessible
  end
end
