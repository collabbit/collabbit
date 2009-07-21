Paperclip.interpolates :instance_id do |attachment, style|
  attachment.instance.update.incident.instance.to_param
end

Paperclip.interpolates :incident_id do |attachment, style|
  attachment.instance.update.incident.to_param
end

Paperclip.interpolates :update_id do |attachment, style|
  attachment.instance.update.to_param
end