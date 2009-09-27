class AddClosedAtToIncidents < ActiveRecord::Migration
  def self.up
    add_column :incidents, :closed_at, :datetime
  end

  def self.down
    remove_column :incidents, :closed_at
  end
end
