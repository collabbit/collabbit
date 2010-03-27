# Controller for operations on groups in the database.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class GroupsController < AuthorizedController

  def new
    @group = Group.new
    @group_type = @instance.group_types.find(params[:group_type_id])
    return with_rejection unless @current_user.can?(:create => Group)
  end

  def show
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @current_user.can?(:view => @group)
  end

  def edit
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @current_user.can?(:update => @group)
  end

  def index
    @group_type = @instance.group_types.find(params[:group_type_id])
    return with_rejection unless @current_user.can? :view => @group_type, :list => @group_type.groups
  end

  # Saves a group object to the database with the parameters provided in
  # the :group hash, which is populated by the form on the 'new' page
  def create
    flash = {}
    return with_rejection unless @current_user.can?(:create => Group)

    @group_type = @instance.group_types.find(params[:group_type_id])
    @group = @group_type.groups.build(params[:group])
    # there's probably a better way to do this...
    @group_type.groups_count = @group_type.groups.length

    if @group.save && @group_type.save
      flash[:notice] = t('notice.group.created')
      redirect_to group_type_group_path(@group_type, @group)
    else
      flash[:error] = t('error.group.creation_failed', :email => 'support@collabbit.org')
      render :action => 'new'
    end
  end

  # Updates an existing group object in the database specified by its :id.
  # The data to be saved is provided in the :group hash,
  # which is populated by the form on the 'edit' page.
  def update
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @current_user.can?(:update => @group)

    if @group.update_attributes(params[:group])
      flash[:notice] = t('notice.group.updated')
      redirect_to group_type_group_path(@group.group_type, @group)
    else
      flash[:error] = t('error.group.update_failed')
      render :action => 'new'
    end
  end

  # Removes a group object specified by its :id from the database
  def destroy
    @group = @instance.groups.find(params[:id])
    gt = @group.group_type
    return with_rejection unless @current_user.can?(:destroy => @group)
    @group.destroy
    redirect_to group_types_url
  end

end

