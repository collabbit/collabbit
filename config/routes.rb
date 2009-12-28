ActionController::Routing::Routes.draw do |map|
  
  map.resources :admins, :only => [:index, :create, :update, :destroy]
  map.login 'login',        :controller => 'admin_sessions',  :action => 'new'
  map.resource :admin_session
  map.logout 'logout',      :controller => 'admin_sessions',  :action => 'destroy'
  map.signup 'signup',      :controller => 'admins',    :action => 'new'
  map.register 'register',  :controller => 'admins',    :action => 'create'
  
  map.resources :instances, :as => 'for' do |instance|
    instance.resources :incidents do |incident|
      incident.close 'close',	  :controller => 'incidents', :action => 'close'
      incident.resources :updates do |update|
        update.attachment 'attachments/:id', :controller => 'attachments', :action => 'show'
        update.comments 'comments', :controller => 'comments', :action => 'create'
      end
    end
    
    instance.logout 'logout',     :controller => 'sessions',  :action => 'destroy'
    instance.login 'login',       :controller => 'sessions',  :action => 'new'
    instance.register 'register', :controller => 'users',     :action => 'create'
    instance.signup 'signup',     :controller => 'users',     :action => 'new'
    instance.activate 'activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
    instance.forgotpassword 'forgotpassword', :controller => 'users', :action => 'forgot_password'
    instance.resetpassword 'resetpassword', :controller => 'users', :action => 'reset_password'
    instance.vcards 'contacts/vcards/:name.vcf', :controller => 'users', :action => 'vcards'
    instance.resources :users, :as => "contacts" do |u|
      u.resources :permissions
    end
    
    instance.resources :tags
    
    instance.resource :session
    instance.resources :roles
        
    instance.resources :group_types do |gt|
      gt.resources :groups
    end
    
    instance.resources :memberships
  end
  
  map.root :controller => 'home'
  map.home '/:page', :controller => 'home', :action => 'show'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
