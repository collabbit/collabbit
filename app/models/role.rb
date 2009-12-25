# Represents a set of permissions that users can have
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Role < ActiveRecord::Base
  include Authority
  has_many :users
  belongs_to :instance

  has_many :privileges, :dependent => :destroy, :include => :permissions
  has_many :permissions, :through => :privileges
  
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
    [:update, :group, :group_type, :incident, :tag].each do |m|
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
    roles
  end
  
end