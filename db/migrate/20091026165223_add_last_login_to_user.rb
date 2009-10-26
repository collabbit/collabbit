class AddLastLoginToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login, :datetime
    add_column :users, :last_logout, :datetime
  end

  def self.down
    remove_column :users, :last_login
    remove_column :users, :last_logout
  end
end
