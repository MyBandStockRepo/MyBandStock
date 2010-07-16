class RecordedVideosController < ApplicationController
  skip_filter :update_last_location, :only => [ :set_recording_visibility ]
#  before_filter :user_has_site_admin, :except => [ :set_recording_visibility ]
  before_filter :authenticated?
  before_filter :user_is_admin_of_a_band?
  before_filter :user_has_site_admin, :only => [:new, :destroy, :create]
  protect_from_forgery :only => [:create, :update]
  respond_to :js, :html, :only => :set_recording_visibility

  def set_recording_visibility
  # Action called AJAXly by a broadcaster to indicate that the present recording should be listed under the given broadcasting stream
  # Basically this action just toggles the public value of a recording based on input.
  # Required parameters:
  #   streamapi_stream_id, public_hostid, public = ['true' || 'false']
    @result = -1
    unless session[:user_id] && params[:streamapi_stream_id]
      respond_with(@result)
      return false
    end
    user = User.find(session[:user_id])
    stream = StreamapiStream.find(params[:streamapi_stream_id])
    
    unless user && stream && user.can_broadcast_for(stream.band.id)
      respond_with(@result)
      return false
    end
    
    recorded_video = RecordedVideo.where(:public_hostid => params[:public_hostid]).first
    
    # Set the recording's publicity based on the :public parameter, or a config default variable.
    publicity = if params[:public] == 'true'
                  true
                elsif params[:public] == 'false'
                  false
                else
                  nil #(defined?(STREAMAPI_DEFAULT_PUBLIC_RECORDING) ? STREAMAPI_DEFAULT_PUBLIC_RECORDING : false)
                end

    if publicity.nil?
      respond_with(@result)
      return false
    end
    
    if recorded_video.nil?
      # There is no recording row for some reason, so we return false-ish
      respond_with(@result)
      return false
    else
      recorded_video.public = publicity
      recorded_video.save
    end
  
    @result = 1
    @public = publicity
    respond_with(@result, @public)
    # respond_to do |schph0rmat|
    #       schph0rmat.js { render :text => '1' }
    #       schph0rmat.html { render :text => '1' }
    # end
  end

  # GET /recorded_videos
  # GET /recorded_videos.xml
  def index
    if session[:user_id] && @user = User.find(session[:user_id])
      if @user.site_admin
        @recorded_videos = RecordedVideo.all.reverse       
      else
        if params[:band_id] && @band = Band.find(params[:band_id])
          if @band.admins.include?(@user)
            @recorded_videos = @band.recorded_videos.reverse
          else
            redirect_to session[:last_clean_url]
            return false            
          end
        else
          redirect_to session[:last_clean_url]
          return false          
        end
      end
    else     
      redirect_to session[:last_clean_url]
      return false
    end    
  end

  # GET /recorded_videos/1
  # GET /recorded_videos/1.xml
  def show
     if session[:user_id] && @user = User.find(session[:user_id])
        if @user.site_admin
          @recorded_video = RecordedVideo.find(params[:id])        
        else
          if params[:band_id] && @band = Band.find(params[:band_id])
            if @band.admins.include?(@user)
              @recorded_video = RecordedVideo.find(params[:id])
            else
              redirect_to session[:last_clean_url]
              return false            
            end
          else
            redirect_to session[:last_clean_url]
            return false          
          end
        end
      else     
        redirect_to session[:last_clean_url]
        return false
      end


  end

  # GET /recorded_videos/new
  # GET /recorded_videos/new.xml
  def new
    @recorded_video = RecordedVideo.new
    @streamapi_streams = StreamapiStream.find(:all)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recorded_video }
    end
  end

  # GET /recorded_videos/1/edit
  def edit
    if session[:user_id] && @user = User.find(session[:user_id])
       if @user.site_admin
         @recorded_video = RecordedVideo.find(params[:id])   
         @streamapi_streams = StreamapiStream.find(:all)                  
       else
         if params[:band_id] && @band = Band.find(params[:band_id])
           if @band.admins.include?(@user)
             @recorded_video = RecordedVideo.find(params[:id])
             @streamapi_streams = @band.streamapi_streams
           else
             redirect_to session[:last_clean_url]
             return false            
           end
         else
           redirect_to session[:last_clean_url]
           return false          
         end
       end
     else     
       redirect_to session[:last_clean_url]
       return false
     end    
  end

  # POST /recorded_videos
  # POST /recorded_videos.xml
  def create
    @recorded_video = RecordedVideo.new(params[:recorded_video])

    respond_to do |format|
      if @recorded_video.save
        format.html { redirect_to(@recorded_video, :notice => 'Recorded video was successfully created.') }
        format.xml  { render :xml => @recorded_video, :status => :created, :location => @recorded_video }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recorded_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recorded_videos/1
  # PUT /recorded_videos/1.xml
  def update
    @recorded_video = RecordedVideo.find(params[:id])

    respond_to do |format|
      if @recorded_video.update_attributes(params[:recorded_video])
        format.html { redirect_to(:action => 'show', :id => @recorded_video.id, :band_id => params[:band_id], :notice => 'Recorded video was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit', :id => @recorded_video.id, :band_id => params[:band_id] }
        format.xml  { render :xml => @recorded_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recorded_videos/1
  # DELETE /recorded_videos/1.xml
  def destroy
    @recorded_video = RecordedVideo.find(params[:id])
    @recorded_video.destroy

    respond_to do |format|
      format.html { redirect_to(recorded_videos_url) }
      format.xml  { head :ok }
    end
  end
end
