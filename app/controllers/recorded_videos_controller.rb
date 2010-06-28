class RecordedVideosController < ApplicationController
  # GET /recorded_videos
  # GET /recorded_videos.xml
  def index
    @recorded_videos = RecordedVideo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recorded_videos }
    end
  end

  # GET /recorded_videos/1
  # GET /recorded_videos/1.xml
  def show
    @recorded_video = RecordedVideo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recorded_video }
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
    @recorded_video = RecordedVideo.find(params[:id])
    @streamapi_streams = StreamapiStream.find(:all)    
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
        format.html { redirect_to(@recorded_video, :notice => 'Recorded video was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
