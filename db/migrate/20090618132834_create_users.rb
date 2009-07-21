class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :first_name,                :string, :limit => 100, :default => '', :null => true
      t.column :last_name,                 :string, :limit => 100, :default => '', :null => true
      t.column :email,                     :string, :limit => 100
      t.string :desk_phone
      t.string :desk_phone_ext
      t.string :cell_phone
      t.boolean :preferred_is_cell
      t.boolean :wants_alerts
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :state,                     :string, :null => :no, :default => 'pending'
      t.column :deleted_at,                :datetime
      t.references :role
      t.references :instance
      t.references :carrier
    end

  end
   

  def self.down
    drop_table "users"
  end
end
