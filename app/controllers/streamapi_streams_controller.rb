require 'builder'
require 'net/http'
require 'uri'
require 'rexml/document'
include REXML

class StreamapiStreamsController < ApplicationController
respond_to :html, :js

## NOTE THESE FILTERS NEED WORK BEFORE IT GOES LIVE


 protect_from_forgery :only => [:create, :update]
 before_filter :only => :post, :only => [:create, :update] 
 before_filter :authenticated?, :except => [:show, :callback]

  def callback
    render :nothing => true
  # doesn't work correctly
=begin
#    @xml = Builder::XmlMarkup.new
    @cuser = "bobby@mybandstock.com"
    @cpass = "life347"
    @action = params[:action]
    @user = params[:username]
    @pass = params[:password]
    @public_hostid = params[:public_hostid]
    @userip = params[:userip]
    @code = "8"
    
		if (@action == "login" && @user == @cuser && @pass == @cpass)
			@code = "0"
		end
    
#    respond_to do |format|
#    	format.xml  { render :xml => @xml}
#    end
=end
  end
	
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

    user = User.find(session[:user_id])

    lssp = user.live_stream_series_permissions.find_by_live_stream_series_id(@stream.live_stream_series.id)
    if lssp.nil?
      #they are valid mbs users but haven't purchased the stream
      logger.info 'User does not have LiveStreamSeriesPermission for the requested stream.'
      # Just display a message for now.
      layout_on = params[:lightbox].nil?
      render :text => "You have not purchased access to this stream. To do so, visit #{ @stream.live_stream_series.purchase_url }.",
             :layout => layout_on
      return false
    end

    viewer_status_entry = StreamapiStreamViewerStatus.where(:user_id => session[:user_id], :streamapi_stream_id => @stream.id).first

    if (viewer_status_entry.nil?)
      # If this viewer_key doesn't already exist, then make it
      @viewer_key = generate_key(16)
      viewer_status_entry = StreamapiStreamViewerStatus.new
      viewer_status_entry.streamapi_stream = @stream
      viewer_status_entry.user = User.find(session[:user_id])
      viewer_status_entry.viewer_key = @viewer_key
      unless viewer_status_entry.save
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
    unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]      
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


  # GET /streamapi_streams
  # GET /streamapi_streams.xml
  def index
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @streamapi_stream }
    end
  end

  # GET /streamapi_streams/new
  # GET /streamapi_streams/new.xml
  def new
    @streamapi_stream = StreamapiStream.new
		@band_id = params[:band_id]
		@lss_id = params[:live_stream_series_id]
		
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @streamapi_stream }
    end
  end

  # GET /streamapi_streams/1/edit
  def edit
    @streamapi_stream = StreamapiStream.find(params[:id])
  end

  # POST /streamapi_streams
  # POST /streamapi_streams.xml
  def create
    @streamapi_stream = StreamapiStream.new(params[:streamapi_stream])

    respond_to do |format|
      if @streamapi_stream.save
        format.html { redirect_to(@streamapi_stream, :notice => 'Streamapi stream was successfully created.') }
        format.xml  { render :xml => @streamapi_stream, :status => :created, :location => @streamapi_stream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @streamapi_stream.errors, :status => :unprocessable_entity }
      end
    end
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
      format.html { redirect_to(streamapi_streams_url) }
      format.xml  { head :ok }
    end
  end
end
