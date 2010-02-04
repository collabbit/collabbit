require 'test_helper'

class TagTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_ensure_length_in_range :name, 1..64
  should_belong_to :instance
  should_have_many :taggings
  should_have_many :updates, :through => :taggings
end
