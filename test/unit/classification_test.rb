require 'test_helper'

class ClassificationTest < ActiveSupport::TestCase
  should_belong_to :update
  should_belong_to :group
end
