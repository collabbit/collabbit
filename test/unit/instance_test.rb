require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  fixtures :all
  
  should_have_many :incidents, :dependent => :destroy
  should_have_many :updates, :through => :incidents
  should_have_many :users, :dependent => :destroy
  should_have_many :feeds, :through => :users
  should_have_many :group_types, :dependent => :destroy
  should_have_many :groups, :through => :group_types
  should_have_many :roles, :dependent => :destroy
  should_have_many :tags, :dependent => :destroy
  should_have_many :whitelisted_domains, :dependent => :destroy
  
  should_ensure_length_in_range :long_name, 4..255
  should_ensure_length_in_range :short_name, 2..16
  should_validate_presence_of :short_name, :long_name
  should_validate_uniqueness_of :short_name
  should_not_allow_mass_assignment_of :short_name, :incidents, :updates, :users, :feeds, :group_types, :roles, :tags
  should_allow_mass_assignment_of :long_name, :whitelisted_domains
  
  should_not_allow_values_for :short_name, 'f', 'support', 'foo bar', 'heLLo'
end
