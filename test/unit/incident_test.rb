require 'test_helper'

class IncidentTest < ActiveSupport::TestCase
  fixtures :all
  
  should_have_many :updates, :dependent => :destroy
  should_have_many :feeds, :dependent => :destroy
  should_belong_to :instance
  
  should_ensure_length_in_range :name, 2..32
  should_validate_presence_of :name
    
  should_not_allow_mass_assignment_of :updates, :feeds
  should_allow_mass_assignment_of :name, :description, :closed
  
  should_not_allow_values_for :name, 'f', ''
  should_allow_values_for :name, 'f '
  
  should_allow_values_for :description, ''
end
