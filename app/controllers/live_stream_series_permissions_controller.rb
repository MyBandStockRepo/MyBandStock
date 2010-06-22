class LiveStreamSeriesPermissionsController < ApplicationController
  before_filter :authenticated?
  before_filter :user_has_site_admin
  protect_from_forgery :only => [:create, :update]

  # GET /live_stream_series_permissions
  # GET /live_stream_series_permissions.xml
  def index
    @live_stream_series_permissions = LiveStreamSeriesPermission.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @live_stream_series_permissions }
    end
  end

  # GET /live_stream_series_permissions/1
  # GET /live_stream_series_permissions/1.xml
  def show
    @live_stream_series_permission = LiveStreamSeriesPermission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @live_stream_series_permission }
    end
  end

  # GET /live_stream_series_permissions/new
  # GET /live_stream_series_permissions/new.xml
  def new
    @live_stream_series_permission = LiveStreamSeriesPermission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @live_stream_series_permission }
    end
  end

  # GET /live_stream_series_permissions/1/edit
  def edit
    @live_stream_series_permission = LiveStreamSeriesPermission.find(params[:id])
  end

  # POST /live_stream_series_permissions
  # POST /live_stream_series_permissions.xml
  def create
    @live_stream_series_permission = LiveStreamSeriesPermission.new(params[:live_stream_series_permission])

    respond_to do |format|
      if @live_stream_series_permission.save
        format.html { redirect_to(@live_stream_series_permission, :notice => 'Live stream series permission was successfully created.') }
        format.xml  { render :xml => @live_stream_series_permission, :status => :created, :location => @live_stream_series_permission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @live_stream_series_permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /live_stream_series_permissions/1
  # PUT /live_stream_series_permissions/1.xml
  def update
    @live_stream_series_permission = LiveStreamSeriesPermission.find(params[:id])

    respond_to do |format|
      if @live_stream_series_permission.update_attributes(params[:live_stream_series_permission])
        format.html { redirect_to(@live_stream_series_permission, :notice => 'Live stream series permission was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @live_stream_series_permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /live_stream_series_permissions/1
  # DELETE /live_stream_series_permissions/1.xml
  def destroy
    @live_stream_series_permission = LiveStreamSeriesPermission.find(params[:id])
    @live_stream_series_permission.destroy

    respond_to do |format|
      format.html { redirect_to(live_stream_series_permissions_url) }
      format.xml  { head :ok }
    end
  end
end
