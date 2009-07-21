class CreateInstances < ActiveRecord::Migration
  def self.up
    create_table :instances do |t|
      t.string :short_name, :limit => 16
      t.string :long_name
      t.timestamps
    end

  end

  def self.down
    drop_table :instances
  end
end
