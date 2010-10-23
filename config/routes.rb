Cobain::Application.routes.draw do |map|
  resources :twitter_crawler_hash_tags

# http://www.engineyard.com/blog/2010/the-lowdown-on-routes-in-rails-3/

  # API methods
  match 'api/test', :to => 'api#test'
  match 'api/change_stream_permission', :to => 'api#change_stream_permission'
  match 'streamapi_streams/callback', :to => 'streamapi_streams#callback'
  match 'api', :to => 'api#index'

  match 'live_stream_series/jsonp/:band_short_name/', :to => 'live_stream_series#jsonp'
  match 'live_stream_series/:id/by_band/', :to => 'live_stream_series#by_band'
#  match 'live_stream_series/:id/send_emails/', :to => 'live_stream_series#email_users'


#twitter api
	match '/twitter/create_session', :to => 'twitter_api#create_session'
	match '/twitter/finalize', :to => 'twitter_api#finalize'
	match '/twitter/quick_finalize', :to => 'twitter_api#quick_finalize'	
	match '/twitter/quick_register', :to => 'twitter_api#quick_register'		
	match '/twitter/mentions', :to => 'twitter_api#mentions'
	match '/twitter/index', :to => 'twitter_api#index'
	match '/twitter/show/:id/', :to => 'twitter_api#show'
	match '/twitter/favorites', :to => 'twitter_api#favorites'
	match '/twitter/create', :to => 'twitter_api#create'
	match '/twitter/fav', :to => 'twitter_api#fav'
	match '/twitter/unfav', :to => 'twitter_api#unfav'
	match '/twitter/update', :to => 'twitter_api#update'
	match '/twitter/error', :to => 'twitter_api#error'
	match '/twitter/success', :to => 'twitter_api#success'


  #stream methods
  match '/streams/manage', :to => 'users#control_panel'
	match '/streamapi_streams/listlivestreams', :to => 'streamapi_streams#listLiveStreams'
	match '/streamapi_streams/getlivevideorecordings', :to => 'streamapi_streams#getLiveVideoRecordings'
	match '/streamapi_streams/getlayoutthemes', :to => 'streamapi_streams#getLayoutThemes'
	match '/recorded_videos/set_recording_visibility/:public', :to => 'recorded_videos#set_recording_visibility', :as => 'set_recording_visibility'

  resources :streamapi_streams
  match '/streamapi_streams/new/:band_id', :to => 'streamapi_streams#new'
	match '/streamapi_streams/:id/view', :to => 'streamapi_streams#view'
	match '/streamapi_streams/:id/recorded', :to => 'streamapi_streams#recorded'
	match '/streamapi_streams/:id/broadcast', :to => 'streamapi_streams#broadcast'
	match '/streamapi_streams/:id/getlivesessioninfo', :to => 'streamapi_streams#getLiveSessionInfo'
	match '/streamapi_streams/:id/getpublichostid', :to => 'streamapi_streams#getPublicHostId'
	match '/streamapi_streams/:id/getprivatehostid', :to => 'streamapi_streams#getPrivateHostId'
	match '/streamapi_streams/:stream_id/ping/:viewer_key', :to => 'streamapi_streams#ping'
	match '/streamapi_streams/:id/callback', :to => 'streamapi_streams#callback'
	match '/streamapi_streams/:id/email_stream_reminder', :to => 'streamapi_streams#email_stream_reminder'

	match '/users/activate', :to => 'users#activate'


  # ---- Band Actions ---- #
	  match 'bands/:band_id/buy_stock', :to => 'bands#buy_stock', :as => :buy_stock
	  match 'bands/:band_id/make_stock_purchase', :to => 'merchant#make_stock_purchase', :as => :make_stock_purchase
    match 'bands/:band_id/is_band_broadcasting_live', :to => 'bands#is_band_broadcasting_live'
    match 'bands/:band_id/leaderboard', :to => 'bands#leaderboard_widget'
  # /--- Band Actions ---- #


  # ---- Share Codes ---- #
    match '/redeem_code(/:mbs_share_code)', :to => 'share_codes#redeem', :as => 'redeem_code'
    match 'share_codes/redeem', :to => 'share_codes#redeem'
    match '/share_codes/complete_redemption', :to => 'share_codes#complete_redemption'

    #match '/share_code_groups', :to => 'share_code_groups#index'
    match '/share_code_groups/download(/:id/:band_id)', :to => 'share_code_groups#download'
    match '/share_code_groups/:id/:band_id', :to => 'share_code_groups#show'

  # /--- Share Codes ---- #


  # ---- Administration ---- #
    match 'admin', :to => 'admin#index', :as => 'admin'
    match 'admin/grant_shares', :to => 'admin#grant_shares', :as => 'grant_shares'
    match '/admin/email_users', :to => 'admin#email_users_form'
    match '/admin/send_users_email', :to => 'admin#send_users_email'
  # /--- Administration ---- #
  
  
  resources :streamapi_stream_themes
  resources :facebook_publishers
  resources :share_code_groups
  resources :recorded_videos
  resources :pledged_bands
  resources :associations
  resources :share_codes
  resources :short_urls
  resources :api_users
  resources :pledges
  resources :roles
  resources :users
  resources :fans
  resources :bands
  resources :user_roles
  resources :twitter_users
  resources :twitter_crawler_hash_tags  
  resources :live_stream_series
  resources :live_stream_series_permissions
  #codingisanart


	match '/legal/privacy_policy', :to => 'legal#privacy_policy'
	match '/legal/tos', :to => 'legal#tos'


  # ---- Developer Center ---- #
    match 'developers', :to => 'developer#index'
    match 'developers/live_streams_widget', :to => 'developer#live_streams_widget'
    match 'developers/leaderboard_widget', :to => 'developer#leaderboard_widget'
  # /--- Developer Center ---- #
  
  
  # ---- URL Shortener ---- #
    match 'short/favicon.ico', :to => 'statics#favicon_ico'  #can I serve a static asset here? I think .htaccess might have to be used for this.
    match '/short/robots.txt', :to => 'statics#robots_txt'
    match 'short(/:key)', :to => 'short_urls#redirect'
  # /--- URL Shortener ---- #

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

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
  match '/band_home(/:band_id)', :to =>'application#band_home'
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
  match '/register/twitter', :to => 'users#register_with_twitter'

  #users routes - this is stuff like '/users/edit' but it looks better this way
  match '/me/account', :to => 'users#edit'
  match '/me/control_panel', :to => 'users#control_panel'
  match '/me/forgot_password', :to => 'login#forgot_password'
  match '/me/home', :to => 'users#control_panel'
#  match '/me/manage_friends', :to => 'users#manage_friends'
  match '/me/profile', :to => 'users#show'




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
  match '/band_control_panel', :to => 'users#control_panel'
#  map.connect ':band_short_name/manage_fans', :controller => 'bands', :action => 'manage_fans'
#  map.connect ':band_short_name/manage_project', :controller => 'bands', :action => 'manage_project'
#  map.connect ':band_short_name/manage_perks', :controller => 'bands', :action => 'manage_perks'
#  map.connect ':band_short_name/manage_music', :controller => 'bands', :action => 'manage_music'
#  map.connect ':band_short_name/manage_photos', :controller => 'bands', :action => 'manage_photos'
  match ':band_short_name/manage_users', :to => 'bands#manage_users'

	match '/:band_short_name/social_networks/index', :to => 'social_networks#index'

	# Uncomment the following when we have band public profiles
	#match '/bands/:band_short_name', :to =>  'bands#show'


  # PROD ROUTES

  #CONTROLLER: FANS
  map.store_band_name '/store_band_name', :controller => 'fans', :action => 'store_band_name'

  map.fan_new_suggestions '/pledge_bands/:band_name', :controller => 'fans', :action => 'new'

  map.fans '/fans/create', :controller=>"fans", :action=>"create", :conditions => { :method => :post }

  map.fan_pledged '/pledge_bands/:band_id/:fan_id/pledged', :controller => 'fans', :action => 'fan_pledged'

  map.fan_shared '/pledge_bands/:band_id/:fan_id/shared', :controller => 'fans', :action => 'fan_shared'

#  map.get_rid_of_dupes '/fans/clean', :controller => 'fans', :action => 'get_rid_of_dupes'
#    map.consolidate_fans '/fans/consolidate', :controller => 'fans', :action => 'consolidate_fans'
#    map.delete_fans '/fans/delete', :controller => 'fans', :action => 'delete_fans'


  #CONTROLLER: PLEDGED_BANDS
  map.connect '/pledged_bands.js', :controller => 'pledged_bands', :action => 'index'


  #ROOT: CONTROLLER PLEDGES
  map.root :controller => "pledges", :action => "new"

   #CONTROLLER: DASHBOARD
  map.dashboard 'dashboard', :controller => 'dashboard', :action => 'home'

  map.admin_new_entry 'dashboard/new_entry', :controller => 'dashboard', :action => 'admin_new_entry'

  map.admin_new_entry_create 'dashboard/admin_new_entry_create', :controller => 'dashboard', :action => 'admin_new_entry_create'

  map.home_refine_band '/home_refine_band', :controller => 'dashboard', :action => 'home_refine_band'

  map.export_all_bands '/export_to_xls', :controller => 'dashboard', :action => 'export_all'

  map.export_by_bands '/export_single_to_xls', :controller => 'dashboard', :action => 'export_by_band'

   #CONTROLLER: STATICS
  map.pbands 'pledge_bands', :controller => 'statics', :action => 'pbands'
  map.faq 'faq', :controller => 'statics', :action => 'faq'
  map.about 'about', :controller => 'statics', :action => 'about'
  match 'status_404', :to => 'statics#status_404', :as => 'status_404'
  match 'broadcast_faq', :to => 'statics#broadcast_faq'
  match '/support', :to => 'statics#support', :as => 'support'

  # Install the default routes as the lowest priority.
  match ':controller(/:action)'
  match '/:controller(/:id(/:action))'

  match '/:band_short_name', :to => 'bands#show', :as => 'band_stage'

end
