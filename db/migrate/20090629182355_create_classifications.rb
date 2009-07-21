class CreateClassifications < ActiveRecord::Migration
  def self.up
    create_table :classifications do |t|
      t.references :group
      t.references :update

      t.timestamps
    end
  end

  def self.down
    drop_table :classifications
  end
end
