class Attachment < ActiveRecord::Base
  include Authority
  
  belongs_to :update
  owned_by :update
  
  has_attached_file :attach,
    :path => ":rails_root/attachments/:instance_id/:id/:basename.:extension",
    :url => "/for/:instance_id/incidents/:incident_id/updates/:update_id/attachments/:id"
  validates_attachment_size :attach, :less_than => 5.megabytes
  attr_protected :attach_file_name, :attach_content_type, :attach_file_size, :attach_updated_at
end
