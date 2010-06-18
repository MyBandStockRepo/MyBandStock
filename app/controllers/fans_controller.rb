# before_filter :authenticated?, :only => [:get_rid_of_dupes, :consolidate_fans, :delete_fans]
#  before_filter :user_has_site_admin, :only => [:get_rid_of_dupes, :consolidate_fans, :delete_fans]

class FansController < ApplicationController

  ###################################
          #NON REST ACTIONS#
  ###################################
  def store_band_name        
    unless params[:band][:search_text] == "" || params[:band][:search_text] == "Find Your Favorite Artist"
      #get raw input band string
      raw_band_name = params[:band][:search_text]
      #downcase and titelize raw input band string
      raw_band_name.downcase!
      band_name = raw_band_name.split(' ').collect {|word| word.capitalize}.join(" ")
      #Assign the band name string for /bands/:band_name URL
      band_string_url = band_name.gsub(' ', '-').downcase
      redirect_to :action => 'new', :band_name => band_string_url
    else
      redirect_to :back
    end  
  end
  
  def fan_pledged
     @pledged_band = PledgedBand.find_by_id(params[:band_id])
     @fan = Fan.find_by_id(params[:fan_id])
    render :action => 'fan_pledged'
  end
  
  def fan_shared
    @pledged_band = PledgedBand.find_by_id(params[:band_id])
    @fan = Fan.find_by_id(params[:fan_id])
    
    #SET URL VARIABLES
    #@band_id = @band_name.id
    #@fan_id = @fan.id
    
#    flash[:user_action_to_publish] = FacebookPublisher.create_publish_battle(@pledged_band, @pledged_band, @pledged_band, session[:facebook_session])
    
    render :action => "fan_share", :locales => { @pledged_band, @fan }
  end

   ###################################
   ###################################
   
  # GET /fans
  # GET /fans.xml
  # def index
  #  @fans = Fan.all
  #
  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.xml  { render :xml => @fans }
  #  end
  #end 


  # GET /fans/1
  # GET /fans/1.xml
  #def show
  #  @fan = Fan.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.xml  { render :xml => @fan }
  #  end
  #end

  # GET /fans/new
  # GET /fans/new.xml
  #The new action gets a pledged_band name (either existing or new) and returns the suggestion view + /:pledged_band URL
  def new
  
    #Assign params variable
    hypenated_band_name = params[:band_name]
    
    #downcase and titelize band name from :band_name URL string (with -)
    hypenated_band_name.downcase!
    @band_name = hypenated_band_name.split('-').collect {|word| word.capitalize}.join(" ")
    
    #Find band name and get pledges number (0 for new created ones) 
    pledged_band = PledgedBand.find_by_name(@band_name)
    pledged_band.nil? ? @band_pledges_number = 0 : @band_pledges_number = Pledge.find_all_by_pledged_band_id(pledged_band).size    
    render :action => 'new'
  end

  # GET /fans/1/edit
  #def edit
  #  @fan = Fan.find(params[:id])
  #end

  # POST /fans
  # POST /fans.xml
  def create
    
    @fan = Fan.new(params[:fan])
    new_pledged_band = params[:fan][:fan_new_pledged_band]

	@fan.email = @fan.email.downcase

	#Finds or Creates NEW Pledged Band
	@pledged_band = @pledged_band = PledgedBand.find_or_create_by_name(:name => new_pledged_band)

	# run check for duplicate email
	fan_with_email = Fan.find(:first, :conditions=>["email = ?", @fan.email])

	@error = 0

    if fan_with_email != nil
		#fan already in table
		@fan = fan_with_email
   		@band_pledge = Pledge.find(:first, :conditions=>["fan_id = ? AND pledged_band_id = ?", fan_with_email.id, @pledged_band.id])
			
		if @band_pledge != nil
			#fan already made pledge
			@error = 1			
		end		
		
	else
		#fan not in table
		if !@fan.save        
			#fan didn't save correctly
			@error = 2
        end
	end




    respond_to do |format|
       if @error == 0                
			#Creates new pledge
			@pledge = Pledge.create(:fan_id => @fan.id, :pledged_band_id => @pledged_band.id)
					
			#KEEP FAN FULLNAME & EMAIL IN SESSION. IF FAN REPLEDGES PREPOPULATE INPUT FIELDS 
			session[:full_name] = @fan.full_name
			session[:email] = @fan.email
			format.html { redirect_to fan_pledged_url(:band_id => @pledged_band.id, :fan_id => @fan.id) }        
			format.xml  { render :xml => @fan, :status => :created, :location => @fan }
	  elsif @error == 1
			band = PledgedBand.find_by_name(new_pledged_band)
			@band_name = band.name
			@band_pledges_number = band.pledges_count
			flash[:error] = "You have already made a suggestion for this band."
			format.html { render :action => "new", :locales => {@band_name,@band_pledges_number} }
			format.xml  { render :xml => @fan.errors, :status => :unprocessable_entity }	
	   else
			band = PledgedBand.find_by_name(new_pledged_band)
			@band_name = band.name
			@band_pledges_number = band.pledges_count
			format.html { render :action => "new", :locales => {@band_name,@band_pledges_number} }
			format.xml  { render :xml => @fan.errors, :status => :unprocessable_entity }		   
      end
    end
  end

  # PUT /fans/1
  # PUT /fans/1.xml
  #def update
  #  @fan = Fan.find(params[:id])
  
  #  respond_to do |format|
  #    if @fan.update_attributes(params[:fan])
  #      flash[:notice] = 'Fan was successfully updated.'
  #      format.html { redirect_to(@fan) }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @fan.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /fans/1
  # DELETE /fans/1.xml
  #def destroy
  #  @fan = Fan.find(params[:id])
  #  @fan.destroy

  #    respond_to do |format|
  #    format.html { redirect_to(fans_url) }
  #    format.xml  { head :ok }
  #  end
  #end
  
  
  def get_rid_of_dupes
  
  	# get rid of duplicate pledges
  	pledges = Pledge.find(:all)
  	
  	for pl1 in pledges
  		for pl2 in pledges
  			if pl1.id != pl2.id && pl1 != nil && pl2 != nil
  				if pl1.pledged_band_id == pl2.pledged_band_id
  					#do email lookups
  					fan1 = Fan.find(pl1.fan_id)
  					fan2 = Fan.find(pl2.fan_id)
  					
  					if fan1.email == fan2.email && fan1 != nil && fan2 != nil
	  					#same email	  						  					
	  					pl2.destroy			
						get_rid_of_dupes
						return
  					end  					
  				end
  			end
  		end
  	end
  end
  
  
  def consolidate_fans
  	fans = Fan.find(:all)
  	
  	for fn in fans
  		firstfan = Fan.find(:first, :conditions=>["email = ?", fn.email])
  		samefans = Fan.find(:all, :conditions=>["email = ?", fn.email])
  		for smfn in samefans
  			if firstfan.id != smfn.id && firstfan != nil && smfn != nil
  				#find all pledges by smfn
  				pledges = Pledge.find(:all, :conditions=>["fan_id = ?", smfn.id])
  				
  				for pl in pledges
  					pl.fan_id = firstfan.id
  					if pl.update_attributes(params[:pl])
  					end  					
  				end
  			end
  		end
  	
  	end
  
  end
  
  def delete_fans
  	# get rid of duplicate fans
  	fans = Fan.find(:all)
  	
  	for fn in fans
  		firstfan = Fan.find(:first, :conditions=>["email = ?", fn.email])
  		samefans = Fan.find(:all, :conditions=>["email = ?", fn.email])
  		for smfn in samefans
  			if firstfan.id != smfn.id && firstfan != nil && smfn != nil
  				smfn.destroy
  				delete_fans
  				return
  			end
  		end
  	end
  	
  end
  
  
end
