require 'zip/zipfilesystem'
require 'yaml'
require 'FileUtils'
class InstancesController < AuthorizedController
  
  before_filter :setup_editable_permissions, :only => [:update, :edit]
  
  def index
    @instances = Instance.all
    return with_rejection unless @current_user.can? :list => @instances
  end

  def show
    @incidents = @instance.incidents.find(:all,
                                          :include => [:updates],
                                          :order => 'created_at DESC',
                                          :conditions => ['created_at > ?', 2.months.ago.to_i])
    return with_rejection unless @current_user.can? :list => @incidents, :view => @instance
  end

  # Method for displaying the information needed on the 'Edit instance' page,
  # which lets the user edit the name of the instance and the permissions
  # associated with each role.
  # It passes the permissions to the view in a hash in which the
  # permissions are organized by their model.
  def edit
    return with_rejection unless @current_user.can? :update => @instance
    @roles = @instance.roles
  end

  # Updates an existing instance object in the database specified by its :id
  # The data to be saved is provided in the :instance hash,
  # which is populated by the form on the 'edit' page
  # It also saves the updated permissions to the database based
  # on the :permissions hash
  def update
    return with_rejection unless @current_user.can? :update => @instance
    
    if params[:permissions].is_a? Hash
      params[:permissions].each_pair do |role_id, rest|
        role = @instance.roles.find(role_id, :include => [:permissions, :privileges])
        rest.each_pair do |model_name, actions|
          to_delete = @perms_hash[model_name.gsub(/[a-z][A-Z]/) {|m| "#{m[0,1]} #{m[1,2]}"}] - actions.keys
          to_add = actions.keys - role.permissions.find_all_by_model(model_name).map(&:action)
          
          to_delete.each do |act|
            perm = role.permissions.find(:first, :conditions => {:model => model_name, :action => act})
            perm.privileges.find_by_role_id(role.id).destroy if perm
          end
          
          to_add.each do |act|
            role.permissions << Permission.find(:first, :conditions => {:model => model_name, :action => act})
          end
          
          role.save
        end
      end
    end
    if @instance.update_attributes(params[:instance])
      #flash[:notice] = t('notice.instance.updated')
      flash[:notice] = t('notice.instance_.updated')
      redirect_to edit_path
    else
      flash[:error] = t('error.instance.update_failed')
      render edit_path
    end
  end

  # Removes an instance object specified by its :id from the database
  def destroy
    return with_rejection unless @current_user.can? :destroy => @instance
    @instance.destroy
    redirect_to @instance
  end

  def new
    return with_rejection unless @current_user.can? :create => Instance
    @instance = Instance.new
  end

  # Saves an instance object to the database with the parameters provided in
  # the :instance hash, which is populated by the form on the 'new' page
  def create
    return with_rejection unless @current_user.can? :create => Instance
    @instance = Instance.build(params[:instance])
    if @instance.save
      flash[:notice] = t('notice.instance.created')
      redirect_to @instance
    else
      render :action => 'new'
    end
  end
 

  
#export a particular instance
#all the tables associated are exported in the form of yaml files and can be downloaded as zip 
   
def export
  
    export_models = [Incident, Update, Comment, User, Feed, GroupType, Group, Role, Tag, WhitelistedDomain,
                    AttachedFile, Classification, Criterion, GroupTagging, Membership] 
    
    @filename ="#{RAILS_ROOT}/tmp/#{@instance.short_name}.zip"
    
    Zip::ZipOutputStream::open(@filename) do |zip|
      export_models.each do |exp_model| 
        contents = exp_model.send(:export_model,@instance)
        zipentry(zip, exp_model.name.pluralize, contents)
      end
      
      contents = Tagging.send(:export_model,@instance)
      zipentry(zip, "Tagging", contents)
    end
  
    #Add all the files in attachments in a separate folder 
    attachments = AttachedFile.attached_files_arr(@instance)
    Zip::ZipFile::open(@filename) do |zip|
      zip.dir.mkdir("attachments")
      attachments.each do |a|
         zip.add("attachments/#{a.attach.original_filename}", a.attach.path)
      end
    end

    send_file @filename,  :type => 'application/zip',
                            :filename => "#{@instance.short_name}.zip",
                            :disposition => 'attachment'
  
end


#Import imports a particular instance and reproduces it
#All the relationships between various tables is maintained while importing

def import
   
   @dest ="#{RAILS_ROOT}/tmp/out"
   unless params[:zip_file].blank?
      FileUtils.rm_rf(Dir.glob("#{@dest}/*"))
      
      #Open a Zip File that is already present and read
      Zip::ZipFile::open(params[:zip_file].path) do |zipfile|    
         zipfile.each do |entry|
          f_path=File.join(@dest,entry.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zipfile.extract(entry,f_path) unless File.exist?(f_path)
         end
      end
    
      import_models = [Incident, User, Update, Comment, Feed, GroupType, Group, Tag, WhitelistedDomain,
                      AttachedFile, Classification, Criterion, GroupTagging, Tagging, Membership]
         
      import_models.each do |imp_model|
        imp_model.send(:import_model,@instance,@dest)
      end
    end  
    
  redirect_to @instance
end

  def zipentry(zip, str,var)
    zip.put_next_entry ("#{@instance.short_name}_" + str + ".yml")
    zip << var
  end

  protected
    def setup_editable_permissions
      crud = ['create', 'update', 'destroy']
      @perms_hash = { 'Update'      => crud,
                      'Comment'     => crud,
                      'User'        => crud,
                      'Group'       => crud,
                      'Group Type'  => crud,
                      'Incident'    => crud }
    end
end

