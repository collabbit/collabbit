# Controller for operations on incidents in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class IncidentsController < ApplicationController
  def new
    @instance = Instance.find(params[:instance_id])
    @incident = Incident.new
    return with_rejection unless @incident.creatable?
  end

  def show
    @instance = Instance.find(params[:instance_id])
    @incident = @instance.incidents.find(params[:id])
    redirect_to instance_incident_updates_path(@instance, @incident)
    return with_rejection unless @incident.viewable?
  end

  def edit
    @instance = Instance.find(params[:instance_id])
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @incident.updatable?
  end

  def index
    @instance = Instance.find(params[:instance_id])
    @incidents = @instance.incidents
    return with_rejection unless Incident.listable?
  end
  
  # Saves an incident object to the database with the parameters provided in 
  # the :incident hash, which is populated by the form on the 'new' page
  def create
    @instance = Instance.find(params[:instance_id])
    @incident = Incident.new(params[:incident])
    return with_rejection unless Incident.creatable?
    
    @incident.instance = @instance

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
    @instance = Instance.find(params[:instance_id])
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @incident.updatable?
    if @incident.update_attributes(params[:incident])
      flash[:notice] = INCIDENT_UPDATED
      redirect_to instance_incident_path(@instance, @incident)
    else
      render :action => 'new'
    end
  end
  
  # Removes an incident object specified by its :id from the database
  def destroy
    @instance = Instance.find(params[:instance_id])
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @incident.destroyable?
    @incident.destroy
    redirect_to instance_incidents_path(@instance)
  end

  def close
    @instance = Instance.find(params[:instance_id])
    logger.info(("\n\n\n\n\nCLOSE PARAMS #{params}\n\n\n\n\n"))
    @incident = @instance.incidents.find(params[:incident_id])
    return with_rejection unless @incident.updatable?
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
