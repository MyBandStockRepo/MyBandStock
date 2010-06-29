require 'builder'
require 'net/http'
require 'uri'
require 'rexml/document'
include REXML

class StreamapiStreamsController < ApplicationController
respond_to :html, :js

## NOTE THESE FILTERS NEED WORK BEFORE IT GOES LIVE
 protect_from_forgery :only => [:create, :update]
 #before_filter :only => :post, :only => [:create, :update]
 before_filter :authenticated?, :except => [:callback, :ping]
 before_filter :user_has_site_admin, :except => [:ping, :callback, :view, :broadcast, :new, :edit, :create, :update, :show]
 before_filter :user_part_of_or_admin_of_a_band?, :only => [:broadcast]
 skip_filter :update_last_location, :only => [:ping, :update, :create, :destroy, :view, :broadcast, :recorded]

	def ping
  # This method catches the regular JS pings from viewers, and updates the StreamapiStreamViewerStatus table accordingly.
    stream_id = params[:stream_id]
    viewer_key = params[:viewer_key]

    ssvs = StreamapiStreamViewerStatus.where(:viewer_key => viewer_key).first
    if ssvs
      ssvs.touch   # Update timestamp
    end

    render :nothing => true
  end

	def view
		unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end

    @request_uri = root_url

    if @stream.public_hostid.nil?
      @not_live = true
    end

		@external_css = Band.find(@stream.band_id).external_css_link
		if @external_css == ''
			@external_css = nil
		end
    @user = User.find(session[:user_id])
		@theme = StreamapiStreamTheme.find(@stream.viewer_theme_id)

    unless @user.can_view_series(@stream.live_stream_series.id)
      #they are valid mbs users but haven't purchased the stream
      logger.info 'User does not have LiveStreamSeriesPermission for the requested stream.'
      # Just display a message for now.
      @purchase_url = @stream.live_stream_series.purchase_url
      if params[:lightbox].nil?
        render 'not_permitted'
      else
        render 'not_permitted', :layout => 'lightbox'
      end
      return false
    end

    begin
      twitter_client = client(true, false, @stream.band.id)
      @tweets = @stream.band.tweets(twitter_client, 3)
    rescue
      logger.info "Twitter failure"
      @tweets = nil
    end

    viewer_status_entry = StreamapiStreamViewerStatus.where(:user_id => session[:user_id], :streamapi_stream_id => @stream.id).first

    if (viewer_status_entry.nil?)
      # If this viewer_key doesn't already exist, then make it
      @viewer_key = generate_key(16)
      viewer_status_entry = StreamapiStreamViewerStatus.new
      viewer_status_entry.streamapi_stream = @stream
      viewer_status_entry.user = @user
      viewer_status_entry.viewer_key = @viewer_key
      # Do not save the user's IP address. So now we know later that if IP is not present, we haven't heard a ping from the user.
      unless viewer_status_entry.save # Sometimes this line gives us "BusyException: database is locked"
        # Did not pass validation, but we'll let it slide.
        # We will reject the user when his StreamAPI auth callback arrives.
      end
    else  # viewer_key already exists, so this user is probably refreshing the page
      @viewer_key = viewer_status_entry.viewer_key
    end

	  unless params[:lightbox].nil?
      # If our request tells us not to display layout (in a lightbox, for instance)
      render :layout => 'lightbox'
    end
	end


	def broadcast
		#this is the default value for the make public recording button
		#if true it will default so that a recording is made publicly available for the stream
		@public_recording = STREAMAPI_DEFAULT_PUBLIC_RECORDING


	# http://osdir.com/ml/fancybox/2010-04/msg00471.html
    unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end


		@external_css = Band.find(@stream.band_id).external_css_link
		if @external_css == ''
			@external_css = nil
		end

		@theme = StreamapiStreamTheme.find(@stream.broadcaster_theme_id)

    # Sometimes we get double requests from lightboxes. If they came <= 1 seconds(es) apart, a repeat-request is suspected, so we should not
    lastUpdated = Time.now.to_i - @stream.updated_at.to_i
    if (lastUpdated <= 1)
      logger.info "Double GET request suspected, aborting"
  	  unless params[:lightbox].nil?
        # If our request tells us not to display layout (in a lightbox, for instance)
        render :layout => 'lightbox'
      end
      return false
    end

  	apiurl = URI.parse('http://api.streamapi.com/service/session/create')
  	apikey = STREAMAPI_KEY
  	apisecretkey = STREAMAPI_SECRET_KEY
  	apirid = (Time.now.to_f * 100000*10).to_i.to_s

    private_value = (!@stream.public).to_s

    apisig = Digest::MD5.hexdigest(private_value + apikey + apisecretkey + apirid)

		req = Net::HTTP::Post.new(apiurl.path)
		req.set_form_data({:is_video_private=>private_value, :key=>apikey, :rid=>apirid, :sig=>apisig})

    logger.info "Making API POST request."
		res = Net::HTTP.new(apiurl.host, apiurl.port).start {|http| http.request(req) }
    logger.info "Response:\n#{ res.body.to_s }"

		case res
		when Net::HTTPSuccess, Net::HTTPRedirection
			doc = Document.new(res.body)

			code = XPath.first(doc, "//code") { |e| puts e.text }
			for c in code
				c = c.to_s
			end
			code = c.to_s

			if (code == "0")
				#OK
				private_hostid = XPath.first( doc, "//private_hostid" ) { |e| puts e.text }
				for p in private_hostid
					p = p.to_s
				end
				private_hostid = p

				public_hostid = XPath.first( doc, "//public_hostid" ) { |e| puts e.text }
				for p in public_hostid
					p = p.to_s
			  end
				public_hostid = p

				@stream.private_hostid = private_hostid
				@stream.public_hostid = public_hostid

 				if @stream.save

 					@recorded_video = RecordedVideo.create(:public_hostid => @stream.public_hostid, :public => @public_recording, :streamapi_stream_id => @stream.id, :url => nil)



				#	flash[:notice] = "Now broadcasting stream."
				else
#					flash[:notice] = "Error with getting host id."
				end
				#flash[:notice] = "API Call Success: "+apirid+" "+apisig+" "+code + " "+@public_hostid+" "+@private_hostid
			else
				#flash[:notice] = "API Call Success, but bad response (error code" + code+"): "+res.body
#				flash[:error] = "Error with xml response."

			end
		else
			res.error!
		end

	  unless params[:lightbox].nil?
      # If our request tells us not to display layout (in a lightbox, for instance)
      render :layout => 'lightbox'
    end

=begin
		 respond_to do | format |
		 	format.js {render :layout => false}
		 	format.html {}
		 end
=end
	end





	def recorded
		unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end

		@recordings = RecordedVideo.where('streamapi_stream_id = ? AND public = ? AND url != ?', @stream.id, true, nil)
#		@recordings = RecordedVideos.where(:streamapi_id => @stream.id, :public => true)
		if @recordings && @recordings.count > 0
			@recording = @recordings.first
			@vidthumb = @recording.url+'.jpg'
		end

		@external_css = Band.find(@stream.band_id).external_css_link
		if @external_css == ''
			@external_css = nil
		end
    @user = User.find(session[:user_id])
		@theme = StreamapiStreamTheme.find(@stream.viewer_theme_id)

    unless @user.can_view_series(@stream.live_stream_series.id)
      #they are valid mbs users but haven't purchased the stream
      logger.info 'User does not have LiveStreamSeriesPermission for the requested stream.'
      # Just display a message for now.
      @purchase_url = @stream.live_stream_series.purchase_url
      if params[:lightbox].nil?
        render 'not_permitted'
      else
        render 'not_permitted', :layout => 'lightbox'
      end
      return false
    end

    begin
      twitter_client = client(true, false, @stream.band.id)
      @tweets = @stream.band.tweets(twitter_client, 3)
    rescue
      logger.info "Twitter failure"
      @tweets = nil
    end

	  unless params[:lightbox].nil?
      # If our request tells us not to display layout (in a lightbox, for instance)
      render :layout => 'lightbox'
    end
	end





	def getLiveSessionInfo
    unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end

		# Parameters
  	apiurl = 'http://api.streamapi.com/service/session/live'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000*10).to_i
  	apirid = apiridnum.to_s

  	# Additional Parameters
  	apipublichostid = @stream.public_hostid

  	# API Signature
    apisig = Digest::MD5.hexdigest(apikey+apipublichostid+apisecretkey+apirid)

		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

		# Form GET Request
		req, res = res.get(url.path+'?'+'public_hostid='+apipublichostid+'&key='+apikey+'&rid='+apirid+'&sig='+apisig)

		logger.info 'Get Live Session Info API Request'

		doc = Document.new(res)

		@code = XPath.first(doc, '//code') { |e| puts e.text }
		for c in @code
			c = c.to_s
		end
		@code = c.to_s
		logger.info 'Code: ' + @code

		if (@code == '0')
			#OK

			@is_live = XPath.first( doc, '//is_live') { |e| puts e.text }
			for i in @is_live
				i = i.to_s
			end
			@is_live = i.to_s
			logger.info 'Is Live: ' + @is_live

			if @is_live == 'true'
				@public_hostid = XPath.first( doc, '//public_hostid') { |e| puts e.text }
				for p in @public_hostid
					p = p.to_s
				end
				@public_hostid = p.to_s
				logger.info 'Public Host ID: ' + @public_hostid


				@private_hostid = XPath.first( doc, '//private_hostid') { |e| puts e.text }
				for p in @private_hostid
					p = p.to_s
				end
				@private_hostid = p.to_s
				logger.info 'Private Host ID: ' + @private_hostid

				@username = XPath.first( doc, '//username') { |e| puts e.text }
				for u in @username
					u = u.to_s
				end
				@username = u.to_s
				logger.info 'Username: ' + @username

				@start_time = XPath.first( doc, '//start_time') { |e| puts e.text }
				for s in @start_time
					s = s.to_s
				end
				@start_time = s.to_s
				logger.info 'Start Time: ' + @start_time

				@duration = XPath.first( doc, '//duration') { |e| puts e.text }
				for d in @duration
					d = d.to_s
				end
				@duration = d.to_s
				logger.info 'Duration: ' + @duration

				@channel_id = XPath.first( doc, '//channel_id') { |e| puts e.text }
				for c in @channel_id
					c = c.to_s
				end
				@channel_id = c.to_s
				logger.info 'Channel ID: ' + @channel_id

			end
		else
			@msg = XPath.first( doc, '//msg') { |e| puts e.text }
			for m in @msg
				m = m.to_s
			end
			@msg = m.to_s

			logger.info 'API ERROR CODE: '+ @code + ' - ' + @msg

		end
	end



	def listLiveStreams

		# Parameters
  	apiurl = 'http://api.streamapi.com/service/session/live/list'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000*10).to_i
  	apirid = apiridnum.to_s

  	# API Signature
    apisig = Digest::MD5.hexdigest(apikey+apisecretkey+apirid)

		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

		# Form GET Request
		req, res = res.get(url.path+'?'+'key='+apikey+'&rid='+apirid+'&sig='+apisig)

		logger.info 'List Live Sessions'
		logger.info res

		doc = Document.new(res)

		@code = XPath.first(doc, '//code') { |e| puts e.text }
		for c in @code
			c = c.to_s
		end
		@code = c.to_s
		logger.info 'Code: ' + @code

		if (@code != '0')
			@msg = XPath.first( doc, '//msg') { |e| puts e.text }
			for m in @msg
				m = m.to_s
			end
			@msg = m.to_s

			logger.info 'API ERROR CODE: '+ @code + ' - ' + @msg
		else
			@sessions = XPath.each( doc, '//session') { |e| puts e.text }
			@private_hostids = XPath.each(doc, '//private_hostid') { |e| puts e.text }
			@public_hostids = XPath.each(doc, '//public_hostid') { |e| puts e.text }
			@usernames = XPath.each(doc, '//username') { |e| puts e.text }
			@start_times = XPath.each(doc, '//start_time') { |e| puts e.text }
			@durations = XPath.each(doc, '//duration') { |e| puts e.text }
			@channel_ids = XPath.each(doc, '//channel_id') { |e| puts e.text }
			@total_viewers = XPath.each(doc, '//total_viewers') { |e| puts e.text }
			@total_chatters = XPath.each(doc, '//total_chatters') { |e| puts e.text }
	 		@max_viewers = XPath.each(doc, '//max_viewers') { |e| puts e.text }
			@max_chatters = XPath.each(doc, '//max_chatters') { |e| puts e.text }
			@current_viewers = XPath.each(doc, '//current_viewers') { |e| puts e.text }
			@current_chatters = XPath.each(doc, '//current_chatters') { |e| puts e.text }
		end
	end


	def getPublicHostId
    unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end

		# Parameters
  	apiurl = 'http://api.streamapi.com/service/host/id/public'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000*10).to_i
  	apirid = apiridnum.to_s

  	# Additional Parameters
  	apiprivatehostid = @stream.private_hostid

  	# API Signature
    apisig = Digest::MD5.hexdigest(apikey+apiprivatehostid+apisecretkey+apirid)

		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

		# Form GET Request
		req, res = res.get(url.path+'?'+'private_hostid='+apiprivatehostid+'&key='+apikey+'&rid='+apirid+'&sig='+apisig)

		logger.info 'Get Public Host ID'

		doc = Document.new(res)

		@code = XPath.first(doc, '//code') { |e| puts e.text }
		for c in @code
			c = c.to_s
		end
		@code = c.to_s
		logger.info 'Code: ' + @code

		if (@code == '0')
			#OK
			@public_hostid = XPath.first( doc, '//public_hostid') { |e| puts e.text }
			for p in @public_hostid
				p = p.to_s
			end
			@public_hostid = p.to_s
			logger.info 'Public Host ID: ' + @public_hostid


			@private_hostid = XPath.first( doc, '//private_hostid') { |e| puts e.text }
			for p in @private_hostid
				p = p.to_s
			end
			@private_hostid = p.to_s
			logger.info 'Private Host ID: ' + @private_hostid

		else
			@msg = XPath.first( doc, '//msg') { |e| puts e.text }
			for m in @msg
				m = m.to_s
			end
			@msg = m.to_s

			logger.info 'API ERROR CODE: '+ @code + ' - ' + @msg

		end
	end



	def getPrivateHostId
    unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end

		# Parameters
  	apiurl = 'http://api.streamapi.com/service/host/id/private'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000*10).to_i
  	apirid = apiridnum.to_s

  	# Additional Parameters
  	apipublichostid = @stream.public_hostid

  	# API Signature
    apisig = Digest::MD5.hexdigest(apikey+apipublichostid+apisecretkey+apirid)

		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

		# Form GET Request
		req, res = res.get(url.path+'?'+'public_hostid='+apipublichostid+'&key='+apikey+'&rid='+apirid+'&sig='+apisig)

		logger.info 'Get Private Host ID'

		doc = Document.new(res)

		@code = XPath.first(doc, '//code') { |e| puts e.text }
		for c in @code
			c = c.to_s
		end
		@code = c.to_s
		logger.info 'Code: ' + @code

		if (@code == '0')
			#OK
			@public_hostid = XPath.first( doc, '//public_hostid') { |e| puts e.text }
			for p in @public_hostid
				p = p.to_s
			end
			@public_hostid = p.to_s
			logger.info 'Public Host ID: ' + @public_hostid


			@private_hostid = XPath.first( doc, '//private_hostid') { |e| puts e.text }
			for p in @private_hostid
				p = p.to_s
			end
			@private_hostid = p.to_s
			logger.info 'Private Host ID: ' + @private_hostid

		else
			@msg = XPath.first( doc, '//msg') { |e| puts e.text }
			for m in @msg
				m = m.to_s
			end
			@msg = m.to_s

			logger.info 'API ERROR CODE: '+ @code + ' - ' + @msg

		end
	end



	def getLiveVideoRecordings

		# Parameters
  	apiurl = 'http://api.streamapi.com/service/video/list'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000*10).to_i
  	apirid = apiridnum.to_s

		#optional parameters
		if params[:public_hostid].nil?
			apipublic_hostid = ''
		else
			apipublic_hostid = params[:public_hostid]
		end
		if params[:start_date].nil?
			apistart_date = '' # Start creation date (in milliseconds) of videos to be retrieved.
		else
			apistart_date = params[:start_date]
		end
		if params[:end_date].nil?
			apiend_date = '' # Latest creation date (in milliseconds) of videos to be retrieved.
		else
			apiend_date = params[:end_date]
		end

		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

  	#API Signature
		apisig = Digest::MD5.hexdigest(apiend_date+apikey+apipublic_hostid+apistart_date+apisecretkey+apirid)

		urlpath = url.path+'?'+'key='+apikey+'&rid='+apirid+'&sig='+apisig

		if apipublic_hostid != ''
			urlpath += '&public_hostid='+apipublic_hostid
		end

		if apistart_date != ''
			urlpath += '&start_date='+apistart_date
		end

		if apiend_date != ''
			urlpath += '&end_date='+apiend_date
		end

		# Form GET Request
		req, res = res.get(urlpath)


		logger.info 'List Live Sessions'
		logger.info res

		doc = Document.new(res)



		@code = XPath.first(doc, '//code') { |e| puts e.text }
		for c in @code
			c = c.to_s
		end
		@code = c.to_s
		logger.info 'Code: ' + @code

		if (@code != '0')
			@msg = XPath.first( doc, '//msg') { |e| puts e.text }
			for m in @msg
				m = m.to_s
			end
			@msg = m.to_s

			logger.info 'API ERROR CODE: '+ @code + ' - ' + @msg
		else
			@videos = XPath.each(doc, '//video') { |e| puts e.text }
			@video_ids = XPath.each(doc, '//@id') { |e| puts e.id }
			@public_hostids = XPath.each(doc, '//public_hostid') { |e| puts e.text }
			@durations = XPath.each(doc, '//duration') { |e| puts e.text }
			@channel_ids = XPath.each(doc, '//channel_id') { |e| puts e.text }
			@creation_dates = XPath.each(doc, '//creation_date') { |e| puts e.text }
			@filenames = XPath.each(doc, '//filename') { |e| puts e.text }
			@sizes = XPath.each(doc, '//size') { |e| puts e.text }
			@urls = XPath.each(doc, '//url') { |e| puts e.text }
			@embed_codes = XPath.each(doc, '//embed_code') { |e| puts e.text }
		end
	end




	def getLayoutThemes

		# Parameters
  	apiurl = 'http://api.streamapi.com/service/theme/list'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000*10).to_i
  	apirid = apiridnum.to_s

		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

  	#API Signature
		apisig = Digest::MD5.hexdigest(apikey+apisecretkey+apirid)

		urlpath = url.path+'?'+'key='+apikey+'&rid='+apirid+'&sig='+apisig

		# Form GET Request
		req, res = res.get(urlpath)

		logger.info 'List Layout Themes'
		logger.info res

		doc = Document.new(res)

		@code = XPath.first(doc, '//code') { |e| puts e.text }
		for c in @code
			c = c.to_s
		end
		@code = c.to_s
		logger.info 'Code: ' + @code

		if (@code != '0')
			@msg = XPath.first( doc, '//msg') { |e| puts e.text }
			for m in @msg
				m = m.to_s
			end
			@msg = m.to_s

			logger.info 'API ERROR CODE: '+ @code + ' - ' + @msg
		else
			@themes = XPath.each(doc, '//theme') { |e| puts e.text }
			@theme_ids = XPath.each(doc, '//@id') { |e| puts e.id }
			@names = XPath.each(doc, '//name') { |e| puts e.text }
			@widths = XPath.each(doc, '//width') { |e| puts e.text }
			@heights = XPath.each(doc, '//height') { |e| puts e.text }
			@layout_paths = XPath.each(doc, '//layout_path') { |e| puts e.text }
			@skin_paths = XPath.each(doc, '//skin_path') { |e| puts e.text }
		end
	end






  # GET /streamapi_streams
  # GET /streamapi_streams.xml
  def index
    unless user_has_site_admin
      redirect_to '/streams/manage'
      return false
    end
    @streamapi_streams = StreamapiStream.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @streamapi_streams }
    end
  end

  # GET /streamapi_streams/1
  # GET /streamapi_streams/1.xml
  def show
    @streamapi_stream = StreamapiStream.find(params[:id])
		@broadcaster_theme = StreamapiStreamTheme.find(@streamapi_stream.broadcaster_theme_id)
		@viewer_theme = StreamapiStreamTheme.find(@streamapi_stream.viewer_theme_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @streamapi_stream }
    end
  end

  # GET /streamapi_streams/new
  # GET /streamapi_streams/new.xml
  def new
    @streamapi_stream = StreamapiStream.new
		@live_stream_series_id = params[:live_stream_series_id]
		@band_id = params[:band_id] || LiveStreamSeries.find(@live_stream_series_id).band.id

    if @band_id
      @series_list = LiveStreamSeries.where(:band_id => @band_id)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @streamapi_stream }
    end
  end

  # GET /streamapi_streams/1/edit
  def edit
    @streamapi_stream = StreamapiStream.find(params[:id])

    @band_id = params[:band_id] || LiveStreamSeries.find(@streamapi_stream.live_stream_series.id).band.id

    if @band_id
      @series_list = LiveStreamSeries.where(:band_id => @band_id)
    end
  end

  # POST /streamapi_streams
  # POST /streamapi_streams.xml
  def create
    @streamapi_stream = StreamapiStream.new(params[:streamapi_stream])

    respond_to do |format|
      if @streamapi_stream.save
        format.html {
          redirect_to('/me/control_panel', :notice => 'Streamapi stream was successfully created.')
        }
        format.xml  { render :xml => @streamapi_stream, :status => :created, :location => @streamapi_stream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @streamapi_stream.errors, :status => :unprocessable_entity }
      end
    end
    # Redirect to manage CP
  end

  # PUT /streamapi_streams/1
  # PUT /streamapi_streams/1.xml
  def update
    @streamapi_stream = StreamapiStream.find(params[:id])

    respond_to do |format|
      if @streamapi_stream.update_attributes(params[:streamapi_stream])
        format.html { redirect_to(@streamapi_stream, :notice => 'Streamapi stream was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @streamapi_stream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /streamapi_streams/1
  # DELETE /streamapi_streams/1.xml
  def destroy
    @streamapi_stream = StreamapiStream.find(params[:id])
    @streamapi_stream.destroy

    respond_to do |format|
      format.html { redirect_to('/streams/manage', :live_stream_series_id => @streamapi_stream.live_stream_series.id) }
      format.xml  { head :ok }
    end
  end
end
