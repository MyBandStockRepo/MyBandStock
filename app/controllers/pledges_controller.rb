class PledgesController < ApplicationController

  ###################################
  #TO BE REFACTOR in a RESTFUL way
  ###################################
=begin  
  def link_to_facebook_feed
     @pledged_band = PledgedBand.find_by_id(params[:id])
     @message_publish = FacebookPublisher.create_publish_battle(@pledged_band, @pledged_band.name, @pledged_band.name, session[:facebook_session])
     render :action => 'link_to_facebook_feed'
   end
=end
  ###################################
  ###################################
  
  # GET /pledges
  # GET /pledges.xml
  def index
    @pledges = Pledge.all(:include => [:pledged_band, :fan])

    respond_to do |format|
      format.html index.html.erb
      format.xml  { render :xml => @pledges }
    end
  end

  # GET /pledges/1
  # GET /pledges/1.xml
  def show
    @pledge = Pledge.find(params[:id])

    respond_to do |format|
      format.html show.html.erb
      format.xml  { render :xml => @pledge }
    end
  end

  # GET /pledges/new
  # GET /pledges/new.xml
  def new
    @pledge = Pledge.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pledge }
    end
  end

  # GET /pledges/1/edit
  def edit
    @pledge = Pledge.find(params[:id])
  end

  # POST /pledges
  # POST /pledges.xml
  #Creates new pledge. Creates band and User if no IDS are passed
  def create
    
    #Finds or Creates NEW Pledged Band
    pledged_band = PledgedBand.find_or_create_by_name(:name => band_name)
    
    #Creates new USER
    #user = User.create(:name => params[:pledge][:name], :email => params[:pledge][:email])
    
    @pledge = Pledge.new(:fan_id => params[:id], :pledged_band_id => pledged_band.id)
    
    respond_to do |format|
      if @pledge.save
        flash[:notice] = 'Pledge was successfully created.'
        format.html { render :partial => "suggestion" }
        #format.html { redirect_to(@pledge) }
        #format.xml  { render :xml => @pledge, :status => :created, :location => @pledge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pledge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pledges/1
  # PUT /pledges/1.xml
  def update
    @pledge = Pledge.find(params[:id])

    respond_to do |format|
      if @pledge.update_attributes(params[:pledge])
        flash[:notice] = 'Pledge was successfully updated.'
        format.html { redirect_to(@pledge) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pledge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pledges/1
  # DELETE /pledges/1.xml
  def destroy
    @pledge = Pledge.find(params[:id])
    @pledge.destroy

    respond_to do |format|
      format.html { redirect_to(pledges_url) }
      format.xml  { head :ok }
    end
  end
end
