class CreateUpdates < ActiveRecord::Migration
  def self.up
    create_table :updates do |t|
      t.string :title
      t.string :text
      t.references :user
      t.references :incident
      t.references :group
      t.timestamps
    end
  end

  def self.down
    drop_table :updates
  end
end
