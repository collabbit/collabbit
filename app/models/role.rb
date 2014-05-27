class Role < ActiveRecord::Base
  include Authority
  has_many :users
  belongs_to :instance
  
  acts_as_archive

  has_many :permissions, :through => :privileges
  has_many :privileges, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of   :name, :within => 2..32
  
  attr_protected :user_ids, :instance_id
  
  # Returns the default role.
  def self.default
    #TODO: eventually, move this setting into the database under Instance, maybe
    find_by_name DEFAULT_ROLE_NAME
  end
  
  def self.default_setup
    roles = ['Normal User', 'Manager', 'Administrator', 'Super Administrator']
    roles.map! {|r| Role.new(:name => r)}
    [:update, :group, :group_type, :incident, :tag, :comment].each do |m|
      [:create, :show, :list].each do |a|
        roles[0].permissions << Permission.find(:first, :conditions => {:model => m.to_s.camelize, :action => a.to_s})
      end
      [:create, :update, :destroy, :show, :list].each do |a|
        roles[1].permissions << Permission.find(:first, :conditions =>{:model => m.to_s.camelize, :action => a.to_s})
        roles[2].permissions << Permission.find(:first, :conditions =>{:model => m.to_s.camelize, :action => a.to_s})
      end
      [:create, :update, :destroy, :show, :list].each do |a|
        roles[3].permissions << Permission.find(:first, :conditions =>{:model => m.to_s.camelize, :action => a.to_s})
      end
    end
    [:update, :destroy, :show, :list].each do |a|
      roles[2].permissions << Permission.find(:first, :conditions =>{:model => 'User', :action => a.to_s})
      roles[3].permissions << Permission.find(:first, :conditions =>{:model => 'User', :action => a.to_s})
    end
    [:show, :list].each do |a|
      roles[0].permissions << Permission.find(:first, :conditions =>{:model => 'User', :action => a.to_s})
      roles[1].permissions << Permission.find(:first, :conditions =>{:model => 'User', :action => a.to_s})
    end
    for role in roles
      role.permissions << Permission.find(:first, :conditions =>{:model => 'Instance', :action => 'show'})
    end
    roles[3].permissions << Permission.find(:first, :conditions =>{:model => 'Instance', :action => 'update'})
    roles[3].permissions << Permission.find(:first, :conditions =>{:model => 'User', :action => 'create'})
    roles
  end
  
  def self.roles_arr(instance)
    roles = instance.roles.find(:all)
    roles
  end
  
  def self.export_model(instance)
    roles = roles_arr(instance)
    result_roles = roles.to_yaml
    result_roles.gsub!(/\n/,"\r\n")
    result_roles
  end
  
  def self.model_arri(dest)
      Role
      Dir.chdir(dest)
      @rolesfile = Dir.glob("*"+self.name.pluralize + ".yml")
      yfroles = File.open(@rolesfile.to_s)
      roles = YAML.load(yfroles)
      roles
  end
  
  def self.find_role(user,dest)
    roles = self.model_arri(dest)
    @rolename
    roles.each do |role|
      if(user.role_id == role.id)
       @rolename = role.name
       break
      end
    end
   @rolename
  end
 
end
