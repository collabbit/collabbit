class CreateGroupTaggings < ActiveRecord::Migration
  def self.up
    create_table :group_taggings do |t|
      t.references :tag
      t.references :group
    end
  end

  def self.down
    drop_table :group_taggings
  end
end
