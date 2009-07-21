class CreateIncidents < ActiveRecord::Migration
  def self.up
    create_table :incidents do |t|
      t.string :name, :limit => 32
      t.text :description
      t.references :instance

      t.timestamps
    end
    
  end

  def self.down
    drop_table :incidents
  end
end
