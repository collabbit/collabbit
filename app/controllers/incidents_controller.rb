# Controller for operations on incidents in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class IncidentsController < AuthorizedController
  def new    
    @incident = Incident.new
    return with_rejection unless @current_user.can? :create => Incident
  end

  def show    
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :view => @incident
    
    redirect_to instance_incident_updates_path(@instance, @incident)
  end

  def edit    
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :update => @incident
  end

  def index
    @incidents = @instance.incidents
    return with_rejection unless @current_user.can? :list => @incidents
  end
  
  # Saves an incident object to the database with the parameters provided in 
  # the :incident hash, which is populated by the form on the 'new' page
  def create    
    @incident = @instance.incidents.build(params[:incident])
    return with_rejection unless @current_user.can? :create => Incident
        
    @instance.users.each do |u|
      f = Feed.make_my_groups_feed(@incident)
      f.owner = u
      f.save
    end

    if @incident.save
      flash[:notice] = INCIDENT_CREATED
      redirect_to instance_incident_path(@instance, @incident)
    else
      render :action => 'new'
    end
  end
  
  # Updates an existing incident object in the database specified by its :id
  # The data to be saved is provided in the :incident hash, 
  # which is populated by the form on the 'edit' page
  def update
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :update => @incident
    if @incident.update_attributes(params[:incident])
      flash[:notice] = INCIDENT_UPDATED
      redirect_to instance_incident_path(@instance, @incident)
    else
      render :action => 'new'
    end
  end
  
  # Removes an incident object specified by its :id from the database
  def destroy
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @incident
    @incident.destroy
    redirect_to instance_incidents_path(@instance)
  end

  def close
    @incident = @instance.incidents.find(params[:incident_id])
    return with_rejection unless @current_user.can? :update => @incident
    
    if @incident.closed_at
      flash[:notice] = 'Incident reopened'
      @incident.closed_at = nil
      @incident.save
    else
      flash[:notice] = 'Incident closed'
      @incident.closed_at = DateTime.now
      @incident.save
    end
    
    redirect_to instance_incident_path(@instance, @incident)
  end
end
