class StreamapiStreamsController < ApplicationController
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
