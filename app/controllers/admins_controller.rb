# Controller for managing sitewide administrators. 
# Admins are different from users; they do not belong to an instance 
# and have all privileges. 
# The list of admins can be accessed in /admins 
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class AdminsController < AuthorizedController

  skip_before_filter :require_login
  before_filter :require_admin_login
  layout 'home'

  def index
    @admins = Admin.all
  end

  # Saves an admin object to the database with the parameters provided in 
  # the :admin hash, which is populated by the form on the 'new' page
  def create
    @admin = Admin.new(params[:admin])
    if @admin.save
      flash[:notice] = 'Admin has been added successfully.'
      redirect_to @admin
    else
      render :action => 'new'
    end
  end

  # Updates an existing admin object in the database specified by its :id
  # The data to be saved is provided in the :admin hash, 
  # which is populated by the form on the 'edit' page
  def update
    @admin = Admin.find(params[:id])

    if @admin.update_attributes(params[:admin])
      flash[:notice] = 'Admin has been updated successfully.'
      redirect_to @admin
    else
      render :action => 'edit'
    end
  end

  # Removes an admin object specified by its :id from the database
  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy
    redirect_to admins_path
  end  
end