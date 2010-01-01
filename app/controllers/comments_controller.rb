class CommentsController < AuthorizedController
  def create
    return with_rejection unless @current_user.can? :create => Comment
    incident = @instance.incidents.find(params[:incident_id])
    update = incident.updates.find(params[:update_id])
    c = update.comments.build(params[:comment])
    c.user = @current_user
    flash[:error] = 'Unable to save your comment' unless c.save
    redirect_to c.update.incident
  end

  def destroy
    @tag = @instance.tags.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @tag
    @tag.destroy
    flash[:notice] = t('notice.tag_destroyed')
    redirect_to tags_path
  end
end

