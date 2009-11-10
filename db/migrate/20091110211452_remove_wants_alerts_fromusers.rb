class RemoveWantsAlertsFromusers < ActiveRecord::Migration
  def self.up
    remove_column :users, :wants_alerts
  end

  def self.down
    add_column :users, :wants_alerts, :boolean
  end
end
