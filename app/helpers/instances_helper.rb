module InstancesHelper
  def permission_checkbox(role, action, model)
    checked = !!role.permissions.find(:first, :conditions => {:model => model, :action => action})
    check_box_tag("permissions[#{role.id}][#{model}][#{action}]",1,checked)
  end
end
