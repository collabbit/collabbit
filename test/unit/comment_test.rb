require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :all
  
  should_belong_to :user
  should_belong_to :update
  
  should_ensure_length_in_range :body, 2..4096
  should_validate_presence_of :body
end
