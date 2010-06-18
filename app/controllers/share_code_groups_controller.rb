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
  # Code format:
  #   'lss' + 6-char lssID + 12-char(A-Z,1-9)
  # Like:
  #   lss000028gv8K4mF1
    unless ( (@lss = LiveStreamSeries.find(params[:live_stream_series_id])) && (User.find(session[:user_id]).has_band_admin(@lss.band.id)) )
      flash[:notice] = 'Error.'
      redirect_to '/me/control_panel'
      return false
    end
    
    num_codes = params[:num_codes].to_i
    unless ((num_codes > 0) && (num_codes < 1000000))
      flash[:notice] = 'You\'re asking to generate too many codes.  Needs to be less than 1 million and greater than 0.'
      redirect_to session[:last_clean_url]
      return false
    end
    
    share_amount = params[:share_code_group][:share_amount].to_i
    unless ((share_amount > 0) && (share_amount < 1000000))
      flash[:notice] = 'You\'re asking to generate codes that either have negative share amounts or that are worth more than 1 million shares.  Please stay within these limits.'
      redirect_to session[:last_clean_url]
      return false
    end
    
    expires_on = DateTime.strptime(params[:share_code_group][:expires_on], '%m/%d/%Y')
    unless (expires_on > Time.now)
      flash[:notice] = 'You shouldn\'t create a block of codes that is already expired!'
      redirect_to session[:last_clean_url]
      return false
    end
    
    @share_code_group = ShareCodeGroup.create(:share_amount => share_amount, :expires_on => expires_on)
    
    begin
      ShareCode.transaction do
        num_codes.to_i.times do |i|
          begin
            unique_key = ""
            12.times do
              unique_key += generate_char(SecureRandom.random_number(34))
            end
            key_code = sprintf("LSS%.6u", @lss.id) + unique_key
          end while(ShareCode.where(:key => key_code).first)
          #then create the record
          ShareCode.create( :key => key_code,
                            :redeemed => false,
                            :user_id => nil,
                            :share_code_group_id => @share_code_group.id )                                  
        end #end num_times loop
      end

      respond_to do |format|
        format.html { redirect_to(@share_code_group, :notice => 'Share code group was successfully created.') }
        format.xml  { render :xml => @share_code_group, :status => :created, :location => @share_code_group }
      end
    rescue
      flash[:notice] = 'Key generation failed!!!  Please notify someone.'
      respond_to do |format|
        format.html { redirect_to(new_share_code_group_url) }
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
    unless (@user.site_admin)
      flash[:notice] = 'Error.  Sorry.'
      redirect_to '/me/control_panel'
      return false
    end
    
    @share_code_group = ShareCodeGroup.find(params[:id])
    @share_code_group.destroy

    respond_to do |format|
      format.html { redirect_to(share_code_groups_url) }
      format.xml  { head :ok }
    end
  end


private

  def generate_char(num)
    num %= 35
    case num
    when 0..8
      return (num+1).to_s
    when 9..34
      return (num+56).chr
    end
  end

end
