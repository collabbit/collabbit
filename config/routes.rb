ActionController::Routing::Routes.draw do |map|
  
  # map.resources :admins, :only => [:index, :create, :update, :destroy]
  # map.login 'login',        :controller => 'admin_sessions',  :action => 'new'
  # map.resource :admin_session
  # map.logout 'logout',      :controller => 'admin_sessions',  :action => 'destroy'
  # map.signup 'signup',      :controller => 'admins',    :action => 'new'
  # map.register 'register',  :controller => 'admins',    :action => 'create'
  
  map.with_options :controller => 'instances' do |instances|
    instances.overview  'overview',         :action => 'show'

    instances.edit      'settings/edit',    :action => 'edit'
    instances.update    'settings/update',  :action => 'update'
  end

  
  map.resources :incidents do |incident|
    incident.close 'close',	  :controller => 'incidents', :action => 'close'
    incident.resources :updates do |update|
      update.poll_for_newer 'poll_for_newer', :controller => 'updates', :action => 'poll_for_newer'
      update.attachment 'attachments/:id', :controller => 'attached_files', :action => 'show'
      update.resources :comments, :only => [:create, :destroy]
    end
  end
    
  map.logout 'logout',     :controller => 'sessions',  :action => 'destroy'
  map.login 'login',       :controller => 'sessions',  :action => 'new'
  
  map.register 'register', :controller => 'users',     :action => 'create'
  map.signup 'signup',     :controller => 'users',     :action => 'new'
  map.activate 'activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgotpassword 'forgotpassword', :controller => 'users', :action => 'forgot_password'
  map.resetpassword 'resetpassword', :controller => 'users', :action => 'reset_password'  
  map.vcards 'contacts/vcards/:name.vcf', :controller => 'users', :action => 'vcards'

  map.resources :users, :as => "contacts",
    :collection => {:new_bulk => :get, :create_bulk => :post},
    :member => {:activation_update => :put}
  
  map.resources :tags
  
  map.resource :session
  map.resources :roles
      
  map.resources :group_types do |gt|
    gt.resources :groups
  end
  
  map.resources :memberships

  map.root :overview
  
  map.about 'about', :controller => 'home', :action => 'show', :page => 'index'
  map.home '/:page', :controller => 'home', :action => 'show'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
