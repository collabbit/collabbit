class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.references :group
      t.references :user
      t.boolean :is_chair
    end
  end

  def self.down
    drop_table :memberships
  end
end
