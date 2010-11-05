class PromotionalCodesController < ApplicationController
  before_filter :authenticated?
  before_filter :user_has_site_admin, :except => [:redeem, :redeem_complete]
  protect_from_forgery :only => [:create, :update, :redeem]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new, :redeem]
  layout 'root-layout'


  def redeem
    
  end
  
  def redeem_complete
    @success = false
    #lookup code to see if it exists
    if params[:code] && promo_code = PromotionalCode.where(:code => params[:code].downcase).first 
      #see if code is expired
      if promo_code.start_date.utc < Time.now.utc && Time.now.utc < promo_code.expiration_date.utc
        @user = User.find(session[:user_id])

        #see if user has already redeemed this promo code
        if @user.promotional_codes.where(:id => promo_code.id).count == 0
          @user.promotional_codes << promo_code
          ShareLedgerEntry.create( :user_id => @user.id,
                                   :band_id => promo_code.band.id,
                                   :adjustment => promo_code.share_value,
                                   :description => 'promo_code ' + promo_code.id.to_s
                           )
          flash[:notice] = "Promotional code redeemed for #{promo_code.share_value} BandStock in #{promo_code.band.name}!"
          @success = true

        else
          flash[:error] = "Sorry, you have already redeemed this code."
          redirect_to :action => "redeem"
          return false                   
        end

      else
        flash[:error] = "Sorry, this code has expired."
        redirect_to :action => "redeem"
        return false        
      end
    else
      if params[:code]
        flash[:error] = "No code was found matching \"#{params[:code]}\""
      else
        flash[:error] = "No code was found."
      end
      redirect_to :action => "redeem"
      return false
    end
  end

  # GET /promotional_codes
  # GET /promotional_codes.xml
  def index
    @promotional_codes = PromotionalCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @promotional_codes }
    end
  end

  # GET /promotional_codes/1
  # GET /promotional_codes/1.xml
  def show
    @promotional_code = PromotionalCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @promotional_code }
    end
  end

  # GET /promotional_codes/new
  # GET /promotional_codes/new.xml
  def new
    @promotional_code = PromotionalCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @promotional_code }
    end
  end

  # GET /promotional_codes/1/edit
  def edit
    @promotional_code = PromotionalCode.find(params[:id])
  end

  # POST /promotional_codes
  # POST /promotional_codes.xml
  def create
    @promotional_code = PromotionalCode.new(params[:promotional_code])

    respond_to do |format|
      if @promotional_code.save
        format.html { redirect_to(@promotional_code, :notice => 'Promotional code was successfully created.') }
        format.xml  { render :xml => @promotional_code, :status => :created, :location => @promotional_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @promotional_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /promotional_codes/1
  # PUT /promotional_codes/1.xml
  def update
    @promotional_code = PromotionalCode.find(params[:id])

    respond_to do |format|
      if @promotional_code.update_attributes(params[:promotional_code])
        format.html { redirect_to(@promotional_code, :notice => 'Promotional code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @promotional_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /promotional_codes/1
  # DELETE /promotional_codes/1.xml
  def destroy
    @promotional_code = PromotionalCode.find(params[:id])
    @promotional_code.destroy

    respond_to do |format|
      format.html { redirect_to(promotional_codes_url) }
      format.xml  { head :ok }
    end
  end
end
