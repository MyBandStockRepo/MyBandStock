class StreamapiStreamThemesController < ApplicationController
  before_filter :authenticated?
  before_filter :user_has_site_admin
  protect_from_forgery :only => [:create, :update]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new]
  # GET /streamapi_stream_themes
  # GET /streamapi_stream_themes.xml
  def index
    @streamapi_stream_themes = StreamapiStreamTheme.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @streamapi_stream_themes }
    end
  end

  # GET /streamapi_stream_themes/1
  # GET /streamapi_stream_themes/1.xml
  def show
    @streamapi_stream_theme = StreamapiStreamTheme.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @streamapi_stream_theme }
    end
  end

  # GET /streamapi_stream_themes/new
  # GET /streamapi_stream_themes/new.xml
  def new
    @streamapi_stream_theme = StreamapiStreamTheme.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @streamapi_stream_theme }
    end
  end

  # GET /streamapi_stream_themes/1/edit
  def edit
    @streamapi_stream_theme = StreamapiStreamTheme.find(params[:id])
  end

  # POST /streamapi_stream_themes
  # POST /streamapi_stream_themes.xml
  def create
    @streamapi_stream_theme = StreamapiStreamTheme.new(params[:streamapi_stream_theme])

    respond_to do |format|
      if @streamapi_stream_theme.save
        format.html { redirect_to(@streamapi_stream_theme, :notice => 'Streamapi stream theme was successfully created.') }
        format.xml  { render :xml => @streamapi_stream_theme, :status => :created, :location => @streamapi_stream_theme }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @streamapi_stream_theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /streamapi_stream_themes/1
  # PUT /streamapi_stream_themes/1.xml
  def update
    @streamapi_stream_theme = StreamapiStreamTheme.find(params[:id])

    respond_to do |format|
      if @streamapi_stream_theme.update_attributes(params[:streamapi_stream_theme])
        format.html { redirect_to(@streamapi_stream_theme, :notice => 'Streamapi stream theme was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @streamapi_stream_theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /streamapi_stream_themes/1
  # DELETE /streamapi_stream_themes/1.xml
  def destroy
    @streamapi_stream_theme = StreamapiStreamTheme.find(params[:id])
    @streamapi_stream_theme.destroy

    respond_to do |format|
      format.html { redirect_to(streamapi_stream_themes_url) }
      format.xml  { head :ok }
    end
  end
end
