require 'test_helper'

class CarrierTest < ActiveSupport::TestCase
  should_allow_mass_assignment_of :name, :extension
  should_ensure_length_in_range :name, 1..64
  should_ensure_length_in_range :extension, 1..64
  should_validate_presence_of :name, :extension
end
