ActionController::Routing::Routes.draw do |map|
  
  map.login 'login',        :controller => 'sessions',  :action => 'new'
  map.logout 'logout',      :controller => 'sessions',  :action => 'destroy'
  map.signup 'signup',      :controller => 'admins',    :action => 'new'
  map.register 'register',  :controller => 'admins',    :action => 'create'
  map.resources :admins do |admin|
    admin.resource :session
  end
  
  map.resources :instances, :as => 'for' do |instance|
    instance.resources :incidents do |incident|
      incident.resources :updates do |update|
        update.attachment 'attachments/:id', :controller => 'attachments', :action => 'show'
      end
    end
    
    instance.logout 'logout',     :controller => 'sessions',  :action => 'destroy'
    instance.login 'login',       :controller => 'sessions',  :action => 'new'
    instance.register 'register', :controller => 'users',     :action => 'create'
    instance.signup 'signup',     :controller => 'users',     :action => 'new'
    instance.activate 'activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
    instance.forgotpassword 'forgotpassword', :controller => 'users', :action => 'forgotpassword'
    instance.resetpassword 'resetpassword', :controller => 'users', :action => 'resetpassword'
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
