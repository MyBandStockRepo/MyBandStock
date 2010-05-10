class ApiController < ApplicationController

  def change_stream_permission
    if (params[:api_key].nil? || params[:secret_key].nil? || params[:api_version].nil?)
      @output = false
      respond_to do |format|
        format.xml  { render :xml => @output }
        format.json  { render :json => @output }
        # format.yaml { render :yaml => @output }
      end
      return
    end

    api_key = params[:api_key]
    secret_key = params[:secret_key]
    response_format = params[:format]
    hash = Digest::MD5.hexdigest(api_key + secret_key) if params[:auto_generate_hash].nil? else params[:hash]\
    
    if (response_format.nil?)
      response_format = 'json'
    end

    @output = { :test1 => 'asdf', :test2 => 'asdf2' }
#    respond_to do |format|
#      format.xml { render :xml => @output }
#      format.json  { render :json => @output }
#      # format.yaml { render :yaml => @output }
#    end
    if (response_format == 'json')
      render :json => @output
    elsif (response_format == 'xml')
      render :xml => @output
    elsif (response_format == 'yaml')
      return :render @output.to_yaml
    end
  end

  def test
  end












  # GET /bands
  # GET /bands.xml
  def index
    @bands = Band.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bands }
    end
  end

  # GET /bands/1
  # GET /bands/1.xml
  def show
    @band = Band.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @band }
    end
  end

  # GET /bands/new
  # GET /bands/new.xml
  def new
    @band = Band.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @band }
    end
  end

  # GET /bands/1/edit
  def edit
    @band = Band.find(params[:id])
  end

  # POST /bands
  # POST /bands.xml
  def create
    @band = Band.new(params[:band])

    respond_to do |format|
      if @band.save
        format.html { redirect_to(@band, :notice => 'Band was successfully created.') }
        format.xml  { render :xml => @band, :status => :created, :location => @band }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @band.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bands/1
  # PUT /bands/1.xml
  def update
    @band = Band.find(params[:id])

    respond_to do |format|
      if @band.update_attributes(params[:band])
        format.html { redirect_to(@band, :notice => 'Band was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @band.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bands/1
  # DELETE /bands/1.xml
  def destroy
    @band = Band.find(params[:id])
    @band.destroy

    respond_to do |format|
      format.html { redirect_to(bands_url) }
      format.xml  { head :ok }
    end
  end
end
