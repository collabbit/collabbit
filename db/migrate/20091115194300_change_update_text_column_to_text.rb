class ChangeUpdateTextColumnToText < ActiveRecord::Migration
  def self.up
    change_column :updates, :text, :text
  end

  def self.down
    change_column :updates, :text, :string
  end
end
