# Adds the check_perms method to ActiveRecord::Base (and thus all models)
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

require 'active_record'

ActiveRecord::Base.class_eval do
  
  # Returns true if user is allowed to perform the action
  def self.check_permissions(action)
    return true if Admin.current
    return false unless User.current # <-- if not logged in, can't have permissions
    perms = User.current.permissions.map.select {|p| p.model == self.to_s}
    (perms.map {|p| p.action.to_sym}).include?(action.to_sym)
  end
  
  def check_permissions(action)
    self.class.send :check_permissions, action
  end
  
  def self.creatable?
    check_permissions(:create)
  end
  
  def creatable?
    check_permissions(:create)
  end
  
  def self.listable?
    check_permissions(:list)
  end
  
  def viewable?
    check_permissions(:show)
  end
  
  def destroyable?
    check_permissions(:destroy) and viewable?
  end
  
  def updatable?
    check_permissions(:update) and viewable?
  end
end

Array.class_eval do
  # Typechecking *would* be nice here
  def listable?
    return false unless at(0).class.instance_methods.include? 'viewable?'
    good = true
    each {|x| good = good && x.viewable? }
    good
  end
end
