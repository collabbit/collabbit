class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.string    :email
      t.string  :crypted_password, :limit => 40
      t.string    :salt, :limit => 40
      t.timestamps
    end
  end

  def self.down
    drop_table :admins
  end
end
