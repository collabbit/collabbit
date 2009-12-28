class CommentsController < AuthorizedController
  def create
    return with_rejection unless @current_user.can? :create => Comment
    incident = @instance.incidents.find(params[:incident_id])
    update = incident.updates.find(params[:update_id])
    c = update.comments.build(params[:comment])
    c.user = @current_user
    flash[:error] = 'Unable to save your comment' unless c.save
    redirect_to [@instance, c.update.incident]
  end
end
