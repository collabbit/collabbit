require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  should_belong_to :tag
  should_belong_to :update
end
