class AddAlertToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :text_alert, :boolean
    add_column :feeds, :email_alert, :boolean
  end

  def self.down
    remove_column :feeds, :text_alert
    remove_column :feeds, :email_alert
  end
end
