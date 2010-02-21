class AddArchiveTables < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update User, Admin, Group, GroupType, Instance, Role, Update
  end

  def self.down
  end
end
