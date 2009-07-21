# Default Roles
normal =      Role.create_or_update(:id => 1, :name => 'Normal User',         :instance_id => 1)
group_chair = Role.create_or_update(:id => 2, :name => 'Group Chair',         :instance_id => 1)
manager =     Role.create_or_update(:id => 3, :name => 'Manager',             :instance_id => 1)
admin =       Role.create_or_update(:id => 4, :name => 'Administrator',       :instance_id => 1)
superadmin =  Role.create_or_update(:id => 5, :name => 'Super Administrator', :instance_id => 1)

# Default Permissions
[:update, :user, :group, :group_type, :incident, :instance, :tag].each do|m|
  [:create, :update, :destroy, :show, :list].each do|a|
    superadmin.permissions << Permission.create({:model => m.to_s.camelize, :action => a.to_s})
  end
end

superadmin.save

# Add Permissions to Roles
normal.permissions << Permission.find(:first, :conditions => {:model => 'Update', :action => 'create'})
normal.save