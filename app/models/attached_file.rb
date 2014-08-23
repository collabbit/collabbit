class AttachedFile < ActiveRecord::Base
  include Authority
  
  belongs_to :update, :counter_cache => true
  owned_by :update
  
  has_attached_file :attach,
    :path => ":rails_root/attachments/:instance_id/:id/:basename.:extension",
    :url => "/incidents/:incident_id/updates/:update_id/attachments/:id"
  validates_attachment_size :attach, :less_than => 20.megabytes
  attr_protected :attach_file_name, :attach_content_type, :attach_file_size, :attach_updated_at

  def self.attachedfilesarr(instance)
    updates = Update.updatesarr(instance)
    incidents = Incident.incidentsarr(instance)
    attachments=Array.new
    incidents.each do |ad|
      updates = ad.updates.find(:all)  
      updates.each do |up|
        attachments += up.attached_files.find(:all)
      end
    end
    attachments
  end

  def self.export_attachments(instance)
    attachments = attachedfilesarr(instance)
    result_attachments = attachments.to_yaml
    result_attachments.gsub!(/\n/,"\r\n")
    result_attachments
  end
end
