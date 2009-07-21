# Represents a set of rules to aggregate updates within an incident
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Feed < ActiveRecord::Base
  
  belongs_to :owner, :class_name => 'User'
  belongs_to :incident
  
  has_many :updates, :through => :incident
  has_many :criterions, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :description

  def filter_updates
    updates.select do |u|
      good = true
      criterions.each do |c|
        good = good && case c.type
          when 'start_date' then Time.parse(c.requirement) < u.created_at  
          when 'end_date' then Time.parse(c.requirement) > u.created_at
          when 'keyword' then u.text.contains?(c.requirement)
          # when 'group_type' then u.group_type == c.requirement
          # when 'group' then u.group == c.requirement
          when 'user' then u.user_id == c.requirement
        end
      end
      good
    end
  end
end