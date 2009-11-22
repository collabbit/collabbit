class CreateWhitelistedDomains < ActiveRecord::Migration
  def self.up
    create_table :whitelisted_domains do |t|
      t.references :instance
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :whitelisted_domains
  end
end
