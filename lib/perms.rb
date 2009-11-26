# Adds the check_perms method to ActiveRecord::Base (and thus all models)
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

require 'active_record'

ActiveRecord::Base.class_eval do
  
  # Returns true if user is allowed to perform the action
  def self.check_permissions_for(user, action)
    return true if Admin.current
    return false unless user || Instance.current.users.include?(user)
    perms = user.permissions.map.select {|p| p.model == self.to_s}
    (perms.map {|p| p.action.to_sym}).include?(action.to_sym)
  end
  
  def check_permissions_for(user, action)
    self.class.send :check_permissions_for, user, action
  end
  
  def self.creatable_by?(user)
    check_permissions_for(user, :create)
  end
  
  def creatable_by?(user)
    check_permissions_for(user, :create)
  end
  
  def self.listable_by?(user)
    check_permissions_for(user, :list)
  end
  
  def viewable_by?(user)
    check_permissions_for(user, :show)
  end
  
  def destroyable_by?(user)
    check_permissions_for(user, :destroy) and viewable_by?(user)
  end
  
  def updatable_by?(user)
    check_permissions_for(user, :update) and viewable_by?(user)
  end
  def self.updatable_by?(user)
    check_permissions_for(user, :update)
  end
end

Array.class_eval do
  # Typechecking *would* be nice here
  def listable_by?(user)
    return false unless at(0).class.instance_methods.include? 'viewable_by?'
    good = true
    each {|x| good = good && x.viewable_by?(user) }
    good
  end
end
