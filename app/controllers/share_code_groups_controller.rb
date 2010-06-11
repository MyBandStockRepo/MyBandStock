class ShareCodeGroupsController < ApplicationController

  before_filter :authenticated?

  layout 'root-layout'

  # GET /share_code_groups
  # GET /share_code_groups.xml
  def index
    @user = User.find(session[:user_id])
    unless @user && params[:band_id] && @user.has_band_admin(params[:band_id])
      if params[:band_id].nil?
        flash[:error] = "Cannot manage share codes - invalid band ID given."
      else
        flash[:error] = "Only band admins can manage share codes."
      end
      redirect_to '/band_home' #session[:last_clean_url]
      return false
    end

    @share_code_groups = ShareCodeGroup.all
    @share_code_group = ShareCodeGroup.new
    @series_list = LiveStreamSeries.where(:band_id => params[:band_id])    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @share_code_groups }
    end
  end

  # GET /share_code_groups/1
  # GET /share_code_groups/1.xml
  def show
    @share_code_group = ShareCodeGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @share_code_group }
    end
  end

  # GET /share_code_groups/new
  # GET /share_code_groups/new.xml
  def new
    unless @user && params[:band_id] && @user.has_band_admin(params[:band_id])
      if params[:band_id].nil?
        flash[:error] = "Cannot manage share codes - invalid band ID given."
      else
        flash[:error] = "Only band admins can manage share codes."
      end
      redirect_to '/band_home' #session[:last_clean_url]
      return false
    end

    @share_code_group = ShareCodeGroup.new
    @series_list = LiveStreamSeries.where(:band_id => params[:band_id])    
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @share_code_group }
    end
  end

  # GET /share_code_groups/1/edit
  def edit
    @share_code_group = ShareCodeGroup.find(params[:id])
  end

  # POST /share_code_groups
  # POST /share_code_groups.xml
  def create
    @share_code_group = ShareCodeGroup.new(params[:share_code_group])
    
    codes_array = generate_codes(params[:share_code_group][:num_share_codes])
    
    ShareCode.transaction do
      begin
        first_code = ShareCode.create({:key => codes_array.pop})
        @share_code_group.start_share_code_id = first_code.id
      rescue
      end
    end
    
    # 1. Lock share_codes table
    # 2. @share_code_group.start_share_code_id = ShareCode.highestID
    # 3. Do stuff
    # 4. Unlock

    respond_to do |format|
      if @share_code_group.save
        format.html { redirect_to(@share_code_group, :notice => 'Share code group was successfully created.') }
        format.xml  { render :xml => @share_code_group, :status => :created, :location => @share_code_group }
      else
        format.html {
          @series_list = LiveStreamSeries.where(:band_id => params[:band_id])
          render :action => "new"
        }
        format.xml  { render :xml => @share_code_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /share_code_groups/1
  # PUT /share_code_groups/1.xml
  def update
    @share_code_group = ShareCodeGroup.find(params[:id])

    respond_to do |format|
      if @share_code_group.update_attributes(params[:share_code_group])
        format.html { redirect_to(@share_code_group, :notice => 'Share code group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @share_code_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /share_code_groups/1
  # DELETE /share_code_groups/1.xml
  def destroy
    @share_code_group = ShareCodeGroup.find(params[:id])
    @share_code_group.destroy

    respond_to do |format|
      format.html { redirect_to(share_code_groups_url) }
      format.xml  { head :ok }
    end
  end

  private
  
  def generate_share_codes(numCodes)
  # Code format:
  #   'lss' + 6-char lssID + [8AZ]
  # Like:
  #   lss000028gv8K4mF1

    codes_array = Array.new
    if numCodes.nil?
      return codes_array
    end
    numCodes.to_i.times do
      codes_array << 'a'
    end
    codes_array
  end

end
