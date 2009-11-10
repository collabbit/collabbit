class AddLastAlertedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_alerted, :datetime
  end

  def self.down
    remove_column :users, :last_alerted
  end
end
