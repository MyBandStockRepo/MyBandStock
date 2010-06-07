class LiveStreamSeriesController < ApplicationController

	before_filter :authenticated?, :except => [:by_band, :jsonp]
	before_filter :user_has_site_admin, :except => [:by_band, :jsonp]
	protect_from_forgery :only => [:create, :update]

  respond_to :html, :js, :xml
  layout :choose_layout

  def choose_layout
    if params[:lightbox]
      'lightbox'
    else
      'live_stream_series'
    end
  end
  
  # GET /live_stream_series
  # GET /live_stream_series.xml
  def index
    @live_stream_series = LiveStreamSeries.all
    respond_with(@live_stream_series)
  end

  # GET /live_stream_series/1
  # GET /live_stream_series/1.xml
  def show
    @live_stream_series = LiveStreamSeries.find(params[:id])

    respond_with(@live_stream_series)
  end

  # GET /live_stream_series/new
  # GET /live_stream_series/new.xml
  def new
    @live_stream_series = LiveStreamSeries.new

    respond_with(@live_stream_series)
  end

  # GET /live_stream_series/1/edit
  def edit
    @live_stream_series = LiveStreamSeries.find(params[:id])
    
    respond_with(@live_stream_series)
  end

  # POST /live_stream_series
  # POST /live_stream_series.xml
  def create
    @live_stream_series = LiveStreamSeries.new(params[:live_stream_series])

    respond_to do |format|
      if @live_stream_series.save
        format.html { redirect_to(@live_stream_series, :notice => 'Live stream series was successfully created.') }
        format.xml  { render :xml => @live_stream_series, :status => :created, :location => @live_stream_series }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @live_stream_series.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /live_stream_series/1
  # PUT /live_stream_series/1.xml
  def update
    @live_stream_series = LiveStreamSeries.find(params[:id])

    respond_to do |format|
      if @live_stream_series.update_attributes(params[:live_stream_series])
        format.html { redirect_to(@live_stream_series, :notice => 'Live stream series was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @live_stream_series.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /live_stream_series/1
  # DELETE /live_stream_series/1.xml
  def destroy
    @live_stream_series = LiveStreamSeries.find(params[:id])
    @live_stream_series.destroy

    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end

  def by_band
    unless ( params[:id] && (@band = Band.includes(:live_stream_series).find(params[:id])) )
      flash[:notice] = 'Bad url parameters.'
    else
  		@external_css = @band.external_css_link
			if @external_css == ''
				@external_css = nil
			end
      @live_stream_series = Rails.cache.fetch "band_#{@band.id}_live_stream_series" do       
        @band.live_stream_series.includes(:streamapi_streams)
      end
    end
    
    if @live_stream_series
      #render :layout => false
      respond_with(@live_stream_series)
    else
      return false
    end
  end

  def jsonp
    # Sooooo slow and inefficient
    unless ( params[:band_short_name] && (@band = Band.includes(:live_stream_series).where(:short_name => params[:band_short_name].downcase).first) )
      return render :nothing => true
    else
      live_stream_series = @band.live_stream_series.includes(:streamapi_streams)
      # Cache not used because on the server, we would get "can't modify frozen object".
      #@live_stream_series = Rails.cache.fetch "band_#{@band.id}_live_stream_series" do
      #  @band.live_stream_series.includes(:streamapi_streams)
      #end
    end

    # Generate hash structure for JSON conversion
    output = Hash.new
    output[:serieses] = live_stream_series.collect{ |series|
      {
        :series_title => series.title,
        :streams => series.streamapi_streams.collect{ |stream|
#          if stream.public
            {
              :id => stream.id,
              :title => stream.title,
              :location => stream.location || '',
              :start_day => stream.starts_at.strftime('%a'),
              :start_date => stream.starts_at.strftime('%b %d, %Y'),
              :start_time => stream.starts_at.strftime('%I:%M %p'),
              :view_link => {
                :url => url_for( :controller => 'streamapi_streams', :action => 'view', :id => stream.id, :lightbox => true ),
                :width => (StreamapiStreamTheme.find(stream.viewer_theme_id).width) ? StreamapiStreamTheme.find(stream.viewer_theme_id).width+50 : 560,
                :height => (StreamapiStreamTheme.find(stream.viewer_theme_id).height) ? StreamapiStreamTheme.find(stream.viewer_theme_id).height+46 : 560
              }
            }
#          end
        }
      }
    }

    output[:band_name] = @band.name
    output['band_id'] = @band.id

    output_json = output.to_json
    logger.info output_json

    return render :json => output_json, :callback => 'accessScheduleJsonCallback'
  end

end #end controller
