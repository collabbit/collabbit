class AddEmailAlertTextAlertColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_alert, :boolean
    add_column :users, :text_alert, :boolean
  end

  def self.down
    remove_column :users, :text_alert
    remove_column :users, :email_alert
  end
end
