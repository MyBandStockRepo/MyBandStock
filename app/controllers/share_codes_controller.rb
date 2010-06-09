class ShareCodesController < ApplicationController

  def redeem
    @share_code = ShareCode.new
    @share_code.key = params[:mbs_share_code]
    render :layout => 'lightbox'
  end

  # GET /share_codes
  # GET /share_codes.xml
  def index
    @share_codes = ShareCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @share_codes }
    end
  end

  # GET /share_codes/1
  # GET /share_codes/1.xml
  def show
    @share_code = ShareCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @share_code }
    end
  end

  # GET /share_codes/new
  # GET /share_codes/new.xml
  def new
    @share_code = ShareCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @share_code }
    end
  end

  # GET /share_codes/1/edit
  def edit
    @share_code = ShareCode.find(params[:id])
  end

  # POST /share_codes
  # POST /share_codes.xml
  def create
    @share_code = ShareCode.new(params[:share_code])

    respond_to do |format|
      if @share_code.save
        format.html { redirect_to(@share_code, :notice => 'Share code was successfully created.') }
        format.xml  { render :xml => @share_code, :status => :created, :location => @share_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @share_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /share_codes/1
  # PUT /share_codes/1.xml
  def update
    @share_code = ShareCode.find(params[:id])

    respond_to do |format|
      if @share_code.update_attributes(params[:share_code])
        format.html { redirect_to(@share_code, :notice => 'Share code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @share_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /share_codes/1
  # DELETE /share_codes/1.xml
  def destroy
    @share_code = ShareCode.find(params[:id])
    @share_code.destroy

    respond_to do |format|
      format.html { redirect_to(share_codes_url) }
      format.xml  { head :ok }
    end
  end
end
