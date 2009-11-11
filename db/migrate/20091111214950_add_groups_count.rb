class AddGroupsCount < ActiveRecord::Migration
  def self.up
    add_column :group_types, :groups_count, :integer, :default => 0

    GroupType.reset_column_information
    GroupType.find(:all).each do |gt|
      GroupType.update_counters gt.id , :groups_count => gt.groups.count
    end

  end

  def self.down
    remove_column :group_types,  :groups_count
  end
end

