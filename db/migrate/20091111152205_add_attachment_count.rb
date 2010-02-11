class AddAttachmentCount < ActiveRecord::Migration
  def self.up
    add_column :updates, :attachments_count, :integer, :default => 0

    Update.reset_column_information
    Update.find(:all).each do |u|
      Update.update_counters u.id, :attachments_count => u.attached_files.size
    end
  end

  def self.down
    remove_column :updates, :attachments_count
  end
end

