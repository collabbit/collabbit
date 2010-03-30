class AttachedFilesController < AuthorizedController
  
  def show
    incident = @instance.incidents.find(params[:incident_id])
    update = incident.updates.find(params[:update_id])
    
    return with_rejection unless @current_user.can? :view => update
    
    attachment = update.attached_files.find(params[:id])
    send_file(attachment.attach.path, :filename => attachment.attach.original_filename)
  end

end
