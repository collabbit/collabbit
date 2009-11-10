class CreateCriterions < ActiveRecord::Migration
  def self.up
    create_table :criterions do |t|
      t.string :kind
      t.string :requirement
      t.references :feed

      t.timestamps
    end
  end

  def self.down
    drop_table :criterions
  end
end
