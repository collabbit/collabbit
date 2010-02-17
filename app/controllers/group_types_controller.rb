# Controller for operations on group_types in the database.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class GroupTypesController < AuthorizedController

  def new
    @group_type = GroupType.new
    return with_rejection unless @current_user.can?(:create => GroupType)
  end

  def show
    @group_type = @instance.group_types.find(params[:id])
    redirect_to group_type_groups_path(@group_type)
  end

  def edit
    @group_type = @instance.group_types.find(params[:id])
    return with_rejection unless @current_user.can? :update => @group_type
  end

  def index
    @group_types = @instance.group_types.find(:all, :order => 'name')
    return with_rejection unless @current_user.can?(:list => @group_types)
  end

  # Saves a group_type object to the database with the parameters provided in
  # the :group_type hash, which is populated by the form on the 'new' page
  def create
    @group_type = @instance.group_types.build(params[:group_type])
    return with_rejection unless @current_user.can?(:create => GroupType)

    if @group_type.save
      flash[:notice] = t('notice.group_type_created')
      redirect_to group_type_path(@group_type)
    else
      render :action => 'new'
    end
  end

  # Updates an existing group_type object in the database specified by its :id
  # The data to be saved is provided in the :group_type hash,
  # which is populated by the form on the 'edit' page
  def update
    @group_type = @instance.group_types.find(params[:id])
    return with_rejection unless @current_user.can? :update => @group_type

    if @group_type.update_attributes(params[:group_type])
      flash[:notice] = t('notice.group_type_updated')
      redirect_to group_type_path(@group_type)
    else
      render :action => 'edit'
    end
  end

  # Removes a group_types object specified by its :id from the database
  def destroy
    @group_type = @instance.group_types.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @group_type

    @group_type.destroy
    redirect_to :action => :index
  end

end

