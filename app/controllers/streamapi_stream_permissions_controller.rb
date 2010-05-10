class StreamapiStreamPermissionsController < ApplicationController
  # GET /streamapi_stream_permissions
  # GET /streamapi_stream_permissions.xml
  def index
    @streamapi_stream_permissions = StreamapiStreamPermission.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @streamapi_stream_permissions }
    end
  end

  # GET /streamapi_stream_permissions/1
  # GET /streamapi_stream_permissions/1.xml
  def show
    @streamapi_stream_permission = StreamapiStreamPermission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @streamapi_stream_permission }
    end
  end

  # GET /streamapi_stream_permissions/new
  # GET /streamapi_stream_permissions/new.xml
  def new
    @streamapi_stream_permission = StreamapiStreamPermission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @streamapi_stream_permission }
    end
  end

  # GET /streamapi_stream_permissions/1/edit
  def edit
    @streamapi_stream_permission = StreamapiStreamPermission.find(params[:id])
  end

  # POST /streamapi_stream_permissions
  # POST /streamapi_stream_permissions.xml
  def create
    @streamapi_stream_permission = StreamapiStreamPermission.new(params[:streamapi_stream_permission])

    respond_to do |format|
      if @streamapi_stream_permission.save
        format.html { redirect_to(@streamapi_stream_permission, :notice => 'Streamapi stream permission was successfully created.') }
        format.xml  { render :xml => @streamapi_stream_permission, :status => :created, :location => @streamapi_stream_permission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @streamapi_stream_permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /streamapi_stream_permissions/1
  # PUT /streamapi_stream_permissions/1.xml
  def update
    @streamapi_stream_permission = StreamapiStreamPermission.find(params[:id])

    respond_to do |format|
      if @streamapi_stream_permission.update_attributes(params[:streamapi_stream_permission])
        format.html { redirect_to(@streamapi_stream_permission, :notice => 'Streamapi stream permission was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @streamapi_stream_permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /streamapi_stream_permissions/1
  # DELETE /streamapi_stream_permissions/1.xml
  def destroy
    @streamapi_stream_permission = StreamapiStreamPermission.find(params[:id])
    @streamapi_stream_permission.destroy

    respond_to do |format|
      format.html { redirect_to(streamapi_stream_permissions_url) }
      format.xml  { head :ok }
    end
  end
end
