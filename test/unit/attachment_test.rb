require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  should_not_allow_mass_assignment_of :attach_file_name, :attach_content_type, :attach_file_size, :attach_updated_at
  should_belong_to :update
end
