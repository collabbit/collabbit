class CommentsController < AuthorizedController
  def create
    return with_rejection unless @current_user.can? :create => Comment
    incident = @instance.incidents.find(params[:incident_id])
    update = incident.updates.find(params[:update_id])
    c = update.comments.build(params[:comment])
    c.user = @current_user
    flash[:error] = 'Unable to save your comment' unless c.save
    redirect_to :back
  end

  def destroy
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:update_id])
    @comment = @update.comments.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @comment
    @comment.destroy
    flash[:notice] = t('notice.comment_destroyed')
    redirect_to(params[:redirect_to] || :back)
  end
end

