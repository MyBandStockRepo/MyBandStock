Cobain::Application.routes.draw do |map|
  resources :twitter_users




  resources :streamapi_stream_themes

# http://www.engineyard.com/blog/2010/the-lowdown-on-routes-in-rails-3/

  # API methods
  match 'api/test', :to => 'api#test'
  match 'api/change_stream_permission', :to => 'api#change_stream_permission'
  match 'streamapi_streams/callback', :to => 'streamapi_streams#callback'
  match 'api', :to => 'api#index'

  match 'live_stream_series/jsonp/:band_id/', :to => 'live_stream_series#jsonp'
  match 'live_stream_series/:id/by_band/', :to => 'live_stream_series#by_band'

  resources :api_users

  resources :live_stream_series

  

  resources :live_stream_series_permissions



#twitter api
	match '/twitter/create_session', :to => 'twitter_api#create_session'      
	match '/twitter/finalize', :to => 'twitter_api#finalize'      
	match '/twitter/mentions', :to => 'twitter_api#mentions'
	match '/twitter/index', :to => 'twitter_api#index'	
	match '/twitter/show/:id/', :to => 'twitter_api#show'	
	match '/twitter/favorites', :to => 'twitter_api#favorites'		
	match '/twitter/create', :to => 'twitter_api#create'			
	match '/twitter/fav', :to => 'twitter_api#fav'			
	match '/twitter/unfav', :to => 'twitter_api#unfav'			
	match '/twitter/update', :to => 'twitter_api#update'			
  
  #stream methods
match '/streamapi_streams/listlivestreams', :to => 'streamapi_streams#listLiveStreams'      
match '/streamapi_streams/getlivevideorecordings', :to => 'streamapi_streams#getLiveVideoRecordings'      
match '/streamapi_streams/getlayoutthemes', :to => 'streamapi_streams#getLayoutThemes'      

  resources :streamapi_streams
match '/streamapi_streams/:id/view', :to => 'streamapi_streams#view'  
match '/streamapi_streams/:id/broadcast', :to => 'streamapi_streams#broadcast'      
match '/streamapi_streams/:id/getlivesessioninfo', :to => 'streamapi_streams#getLiveSessionInfo'      
match '/streamapi_streams/:id/getpublichostid', :to => 'streamapi_streams#getPublicHostId'      
match '/streamapi_streams/:id/getprivatehostid', :to => 'streamapi_streams#getPrivateHostId'      
match '/streamapi_streams/:stream_id/ping/:viewer_key', :to => 'streamapi_streams#ping' 
match '/streamapi_streams/:id/callback', :to => 'streamapi_streams#callback'   




  resources :associations

  resources :user_roles

  resources :roles

  resources :users

  resources :bands

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  #******************************************
  #start connecting the static pretty routes
  #******************************************
    
    
  #captcha routes
  match '/simple_captcha/:action', :to => 'simple_captcha'
  
    
  #main page
  root :to => 'application#index'
  
  
  # Band and Fan home and event splash
  match '/cp', :to => 'application#cp'
  match '/fan_home', :to => 'application#fan_home'
  match '/band_home', :to =>'application#band_home'
#  match '/event_splash', :to => 'application#event_splash'
  
  #login and logout routes
  match '/logout', :to => 'login#logout'
  match '/login', :to => 'login#user'
  match '/login/process_user_login', :to => 'login#process_user_login'
  
  #registration and user routes
  match '/register', :to => 'users#new'
  match '/registration', :to => 'users#new'
  match '/signup', :to => 'users#new'
  match '/sign_up', :to => 'users#new'
  

  #users routes - this is stuff like '/users/edit' but it looks better this way
  match '/me/account', :to => 'users#edit'
  match '/me/control_panel', :to => 'users#control_panel'
#  match '/me/manage_artists', :to => 'users#manage_artists'
#  match '/me/manage_friends', :to => 'users#manage_friends'
  match '/me/profile', :to => 'users#show'
#  match '/me/inbox', :to => 'users#inbox'
#  match '/me/purchases', :to => 'users#purchases'
  match '/access_schedule/:id', :to => 'asdf#test'
  match 'me/forgot_password', :to => 'login#forgot_password'  
  #band public profile
  match ':name/profile', :to => 'bands#show'
  
  #users stuff
  match 'users/edit', :to => 'users#edit'
  
  match 'users/state_select', :to => 'users#state_select'
#  match 'users/upload_headline_photo', :to => 'users#upload_headline_photo'
#  match 'users/blank_headline_photo', :to => 'users#blank_headline_photo'
 
  #contribution_levels stuff
#  map.connect 'contribution_levels/add_perk_to_contribution_level', :controller => 'contribution_levels', :action => 'add_perk_to_contribution_level'
#  map.connect 'contribution_levels/remove_perk_from_contribution_level', :controller => 'contribution_levels', :action => 'remove_perk_from_contribution_level'
  
  #charts stuff
#  map.connect 'charts/:band_short_name/:action/:length', :controller => 'charts'
#  map.connect 'charts/:band_short_name/:action', :controller => 'charts'

=begin  
  #projects non-generic routes
  map.connect 'projects/by_band/:band_short_name', :controller => 'projects', :action => 'by_band'
  map.connect 'projects/waiting_approval', :controller => 'projects', :action => 'waiting_approval'
  map.connect 'projects/recently_completed', :controller => 'projects', :action => 'recently_completed'
  map.connect 'projects/waiting_activation', :controller => 'projects', :action => 'waiting_activation'
  
  #news entries non-generic routes
  map.connect 'news_entries/by_band/:band_short_name', :controller => 'news_entries', :action => 'by_band'
  
  #perks non-generic routes
  map.connect 'perks/by_band/:band_short_name', :controller => 'perks', :action => 'by_band'
  
  #concerts non-generic routes
  map.connect 'concerts/by_band/:band_short_name', :controller => 'concerts', :action => 'by_band'
  #admin routes
#  match 'admin/bands/passcodes', :to => 'admin#band_passcodes_list'
#  match 'admin/projects/waiting', :to => 'admin#waiting_projects'
#  match 'admin/projects/approved', :to => 'admin#approved_projects'
  
  #help routes
  map.connect 'help_articles/by_name/:article_name', :controller => 'help_articles', :action => 'by_name'
  map.connect 'help_articles/faq', :controller => 'help_articles', :action => 'faq'
  map.connect 'help_articles/how_it_works', :controller => 'help_articles', :action => 'how_it_works'
 
  #file routes
  map.connect 'files/songs/:id/:quality', :controller => 'files', :action => 'download'
  
  #map the rest resources
  map.resources :users, :except => :destroy
  map.resources :bands, :except => :destroy  
  map.resources :perks, :except => :destroy
  map.resources :concerts, :except => :destroy
  map.resources :news_entries, :except => :destroy
  map.resources :stage_comments, :except => :destroy
  map.resources :contribution_levels, :except => :destroy
  map.resources :projects, :except => :destroy
  
  map.resources :songs, :except => :destroy
  map.resources :music_albums, :except => :destroy
  map.resources :photos, :except => :destroy
  map.resources :photo_albums, :except => :destroy
  map.resources :ledger_entries, :except => :destroy
  map.resources :associations, :except => :destroy
  map.resources :help_articles, :except => :destroy
  map.resources :roles, :except => :destroy
  map.resources :press_releases, :except => :destroy
  map.resources :band_mails, :except => :destroy
=end  
  
  #MAKE SURE that the user routes stay first (at least above band cp routes)  The way it is right now, the whole /me/something can also look like a band_short_name below  
  
  #band control panel stuff
#  map.connect ':band_short_name/mailbox/inbox', :controller => 'bands', :action => 'inbox' #mail route
  match ':band_short_name/control_panel', :to => 'bands#control_panel'
#  map.connect ':band_short_name/manage_fans', :controller => 'bands', :action => 'manage_fans'
#  map.connect ':band_short_name/manage_project', :controller => 'bands', :action => 'manage_project'
#  map.connect ':band_short_name/manage_perks', :controller => 'bands', :action => 'manage_perks'
#  map.connect ':band_short_name/manage_music', :controller => 'bands', :action => 'manage_music'
#  map.connect ':band_short_name/manage_photos', :controller => 'bands', :action => 'manage_photos'
  match ':band_short_name/manage_users', :to => 'bands#manage_users'
  
	match '/:band_short_name/social_networks/index', :to => 'social_networks#index'  
  
  
  
  # Install the default routes as the lowest priority.
  match ':controller(/:action)'
  match '/:controller(/:id(/:action))'
  
  match '/:one_term', :to => 'search#one_term_url'
  
   
end
