ActionController::Routing::Routes.draw do |map|
  
  map.signup '/signup', :controller => 'users',    :action => 'new'
  map.login  '/login',  :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  
  #将所有对视频文件的访问用download方法进行访问控制
  map.connect 'videos/:id/:style.:format', :controller => 'videos', :action => 'download', :conditions => { :method => :get }
  
  # profiles resource route within a admin namespace:
  map.namespace :admin do |admin|
    # Directs /admin/profiles/* to Admin::ProfilesController (app/controllers/admin/profiles_controller.rb)
    admin.resources :users, :member => { :rm => :delete }
    admin.resources :users do |user|
      user.resources :videos, :member => { :rm => :delete }
    end
    admin.resources :roles
    admin.resources :roles do |role|
      role.resources :users, :member => { :add => :put, :mv => :delete }
    end
    admin.resources :profiles
    admin.resources :videos, :member => { :rm => :delete }
  end  

  map.resources :users
	map.resource :account, :controller => "users"

	map.root :controller => 'videos'
	map.resource :user_session
	map.resources :videos
	map.resources :tags
	map.resources :video_replies
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
