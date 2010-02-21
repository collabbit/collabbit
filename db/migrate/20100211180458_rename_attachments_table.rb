class RenameAttachmentsTable < ActiveRecord::Migration
  def self.up
    rename_table 'attachments', 'attached_files'
    rename_column 'updates', 'attachments_count', 'attached_files_count'
    Update.reset_column_information
    Update.find(:all).each do |u|
      Update.update_counters u.id, 'attached_files_count' => u.attached_files.size
    end
  end

  def self.down
    rename_column 'updates', 'attached_files_count', 'attachments_count'
    rename_table 'attached_files', 'attachments'
  end
end
