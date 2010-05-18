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
 before_filter :authenticated?, :except => [:show]

  def callback
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
	
	
	
	
	
	def view

		unless (@stream = StreamapiStream.find(params[:id]))
      redirect_to session[:last_clean_url]      
      return false
    end
    
		respond_to do | format |
		
			format.js {render :layout => false}
			format.html
		end
	end
	
	
	
	
	
	
	
	def broadcast
	  unless (@stream = StreamapiStream.find(params[:id]))
        redirect_to session[:last_clean_url]      
        return false
      end
	#!params[:nolayout].nil?
    #  # If our request tells us not to display layout (in a lightbox, for instance)
	

  	apiurl = 'http://api.streamapi.com/service/session/create'
  	apikey = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  	apisecretkey = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'
  	apiridnum = (Time.now.to_f * 100000).to_i
  	apirid = apiridnum.to_s
  	
  	apisig = Digest::MD5.hexdigest(apikey+apisecretkey+apirid)
  
		url = URI.parse(apiurl)
		req = Net::HTTP::Post.new(url.path)
		req.set_form_data({:key=>apikey, :rid=>apirid, :sig=>apisig})
		res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
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
				private_hostid = p.to_s
				
				public_hostid = XPath.first( doc, "//public_hostid" ) { |e| puts e.text }
				for p in public_hostid
					p = p.to_s
				end
				public_hostid = p.to_s
				
				@stream.private_hostid = private_hostid
				@stream.public_hostid = public_hostid
				
 				if @stream.save
					flash[:notice] = "Streaming Video!"
				else
					flash[:notice] = "Error with getting host id."				
				end
				#flash[:notice] = "API Call Success: "+apirid+" "+apisig+" "+code + " "+@public_hostid+" "+@private_hostid
			else
				#flash[:notice] = "API Call Success, but bad response (error code" + code+"): "+res.body 		
				flash[:error] = "Error with xml response."
	
			end
		else
			res.error!
		end
		respond_to do | format |
		
			format.js {render :layout => false}
			format.html {}
		end
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
