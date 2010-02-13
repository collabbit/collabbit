require 'test_helper'

class CriterionTest < ActiveSupport::TestCase
  should_belong_to :feed
  should_allow_mass_assignment_of :kind, :requirement
  should_ensure_length_in_range :kind, 1..32
  should_ensure_length_in_range :requirement, 1..64
  should_validate_presence_of :kind, :requirement
  
  should_allow_values_for :kind, 'user_group', 'group', 'keyword'
  should_allow_values_for :requirement, '1'
end
