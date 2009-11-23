class AddMembershipsCount < ActiveRecord::Migration
  def self.up
    add_column :groups, :memberships_count, :integer, :default => 0

    Group.reset_column_information
    Group.all.each do |g|
      Group.update_counters g.id, :memberships_count => g.memberships.size
    end
  end

  def self.down
    remove_column :groups, :memberships_count
  end
end

