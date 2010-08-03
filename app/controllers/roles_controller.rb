class RolesController < AuthorizedController

  def show
    @role = @instance.roles.find(params[:id])
    return with_rejection unless @current_user.can? :view => @role
  end

  def edit
    @role = @instance.roles.find(params[:id])
    return with_rejection unless @current_user.can? :update => @role
  end

  def index
    @roles = @instance.roles
    return with_rejection unless @current_user.can? :list => @roles
  end

  # Updates an existing role in the database based on the parameters
  # provided in the view, which are stored in the :role hash.
  def update
    @role = @instance.roles.find(params[:id])
    return with_rejection unless @current_user.can? :update => @role
    if @role.update_attributes(params[:role])
      flash[:notice] = t('notice.role.updated')
      redirect_to @role
    else
      #<<FIX: need error msg?
      render :action => 'new'
    end
  end

end

