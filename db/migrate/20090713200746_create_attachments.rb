class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :name
      t.column :attach_file_name, :string
      t.column :attach_content_type, :string
      t.column :attach_file_size, :integer
      t.column :attach_updated_at, :datetime
      t.references :update
      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
