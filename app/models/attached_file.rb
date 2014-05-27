class AttachedFile < ActiveRecord::Base
  include Authority
  
  belongs_to :update, :counter_cache => true
  owned_by :update
  
  has_attached_file :attach,
    :path => ":rails_root/attachments/:instance_id/:id/:basename.:extension",
    :url => "/incidents/:incident_id/updates/:update_id/attachments/:id"
  validates_attachment_size :attach, :less_than => 20.megabytes
  attr_protected :attach_file_name, :attach_content_type, :attach_file_size, :attach_updated_at

  def self.attached_files_arr(instance)
    updates = Update.updates_arr(instance)
    incidents = Incident.incidents_arr(instance)
    attachments=Array.new
    incidents.each do |ad|
      updates = ad.updates.find(:all)  
      updates.each do |up|
        attachments += up.attached_files.find(:all)
      end
    end
    attachments
  end

  def self.export_model(instance)
    attachments = attached_files_arr(instance)
    result_attachments = attachments.to_yaml
    result_attachments.gsub!(/\n/,"\r\n")
    result_attachments
  end
  
  def self.model_arri(dest)
    AttachedFile
    Dir.chdir(dest)
    @attfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yfatt = File.open(@attfile.to_s)
    attachments = YAML.load(yfatt)
    attachments
   end
   
   def self.import_model(instance, dest)
      attachments = self.model_arri(dest)
      updates = Update.model_arri(dest)
      ydocs = Incident.model_arri(dest)
      attachments.each do |att|  
      el = -1
      up = nil
      updates.each do |updt|
        el += 1
        up = updt
        break if updt.id == att.update_id
       end
   
      elem=-1
      ydocs.each do |ydoc|
        elem += 1
        break if ydoc.id == up.incident_id
      end
     
      @incident = instance.incidents.find_by_name(ydocs[elem].name.to_s)
      @update = @incident.updates.find_by_title(updates[el].title.to_s)
       
       attachment = @update.attached_files.build(:attach => File.new("attachments/#{att.attach_file_name}"))
       @update.save
   end
  end
end
