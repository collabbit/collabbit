class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.references :tag
      t.references :update
    end
  end

  def self.down
    drop_table :taggings
  end
end
