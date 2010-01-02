class AttachmentsController < ApplicationController
  
  def show
    incident = @instance.incidents.find(params[:incident_id])
    update = incident.updates.find(params[:update_id])
    attachment = update.attachments.find(params[:id])
    send_file(attachment.attach.path, :filename => attachment.attach.original_filename)
  end

end
