class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table "roles" do |t|
      t.string :name, :limit => 32
      t.references :instance
      t.timestamps
    end
  end

  def self.down
    drop_table "roles"
  end
end