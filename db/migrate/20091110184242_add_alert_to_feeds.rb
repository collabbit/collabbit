class AddAlertToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :alert, :boolean
  end

  def self.down
    remove_column :feeds, :alert
  end
end
