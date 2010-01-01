require 'test_helper'

class GroupTypeTest < ActiveSupport::TestCase
  fixtures :all
  
  should_have_many :groups, :dependent => :destroy
  should_belong_to :instance
  
  should_ensure_length_in_range :name, 2..32
  should_validate_presence_of :name
    
  should_not_allow_mass_assignment_of :groups, :instance_id
  should_allow_mass_assignment_of :name
  
  should_not_allow_values_for :name, 'f', ''
  should_allow_values_for :name, 'f '
end
