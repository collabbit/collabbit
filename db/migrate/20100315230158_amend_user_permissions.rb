class AmendUserPermissions < ActiveRecord::Migration
  def self.up
    p = Permission.find(:first, :conditions => {:model => 'User', :action => 'create'})
    p ||= Permission.create(:model => 'User', :action => 'create')
    Role.find_all_by_name('Super Administrator').each do |r|
      r.permissions << p
      r.save
    end
  end

  def self.down
    Permission.find(:first, :conditions => {:model => 'User', :action => 'create'}).destroy
  end
end
