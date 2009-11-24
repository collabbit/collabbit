# Represents an action that a user might need authorization to access 
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Permission < ActiveRecord::Base
  has_many :privileges, :dependent => :destroy
  has_many :roles, :through => :privileges

  def self.generate_all
    actions = [:create, :show, :list, :destroy, :update]
    map = {
        :update => actions,
        :group => actions,
        :group_type => actions,
        :tag => actions,
        :incident => actions,
        :role => actions,
        :user => actions - [:create],
        :instance => [:update]
      }
    map.each_pair do |klass,v|
      v.each do |act|
        Permission.create(:class => klass.to_s.camelize, :action => act.to_s)
      end
    end  
  end
end
