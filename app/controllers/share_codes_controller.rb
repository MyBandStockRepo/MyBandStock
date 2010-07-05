require 'MBS_API'

class ShareCodesController < ApplicationController
  before_filter :authenticated?, :except => [:redeem, :redeem_post, :complete_redemption]
  before_filter :user_has_site_admin, :except => [:redeem, :redeem_post, :complete_redemption]
  protect_from_forgery :only => [:redeem_post, :create, :update]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new, :redeem, :complete_redemption]

  def redeem
    if flash[:error]
      flash[:error] << " If you are having trouble or encountering problems, please email us at #{MBS_SUPPORT_EMAIL}."
    end

    @share_code = ShareCode.new
    @share_code.key = params[:mbs_share_code]
    if session[:user_id]
      @email = User.find(session[:user_id]).email
    end
    
    @email = params[:email] if params[:email]
    
    unless params[:lightbox].nil?
      @external = true
      render :layout => 'lightbox'
    end
  end

  # POST /redeem_post
  def redeem_post
    # If existing user, we:
    #   Redirect_to ShareCodes#complete_redemption
    # If unfamiliar user:
    #   Redirect_to Users#new and have the user "complete the process"
    
    if params[:share_code].nil? || params[:share_code][:key].nil? ||
       params[:email].nil? || params[:share_code][:key] == '' || params[:email] == ''

      flash[:error] = 'You must provide both the Share Code and your email address.'
      redirect_to :action => :redeem,
                  :email => params[:email],
                  :lightbox => params[:lightbox]
      return false
    end
    
    share_code_entry = ShareCode.where(:key => params[:share_code][:key]).first

    # Does code exist?
    if share_code_entry.nil?
      flash[:error] = 'That Share Code is invalid. Please check that you typed it correctly.'
      redirect_to :action => :redeem,
                  :mbs_share_code => params[:share_code][:key],
                  :email => params[:email],
                  :lightbox => params[:lightbox]
      return false
    end
    
    # Check if the share code has already been redeemed
    if share_code_entry.redeemed
      flash[:error] = 'That Share Code has already been redeemed!'
      redirect_to :action => :redeem, :lightbox => params[:lightbox], :email => params[:email]
      return false
    end
    
    # Check if the share code has expired
    if share_code_entry.expired?
      flash[:error] = 'That Share Code has expired.'
      redirect_to :action => :redeem, :lightbox => params[:lightbox], :email => params[:email]
      return false
    end
    
    user = User.where(:email => params[:email]).first
    
    # If the user exists, we send him to complete_redemption
    # If the user does not exist, we send him to create an account
    if user
      redirect_to :action => :complete_redemption,
                  :key => params[:share_code][:key],
                  :user_id => user.id,
                  :lightbox => params[:lightbox]
      return true
    else
      come_back_to = url_for({
                       :controller => 'share_codes',
                       :action => 'complete_redemption'
                     }).to_s
      come_back_to << '?'
      come_back_to << 'key=' + params[:share_code][:key] if params[:share_code][:key]
      come_back_to << '&lightbox=' + params[:lightbox] if params[:lightbox]
                    # user id is added by users/create, just in case the user wants to change it
      logger.info "Telling user/create to redirect back to " + come_back_to + "."
      redirect_to :controller => 'users',
                  :action => 'new',
                  :lightbox => params[:lightbox],
                  :redemption_redirect => come_back_to,
                  :user => { :email => params[:email], :email_confirmation => params[:email] } # params for users/create
      return true
    end

  end

  def complete_redemption
  # The user came here if he already existed in the system or if he just registered.
  # 1. Invalidate code
  # 2. Parse the code to determine which privileges should be granted
  # 3. Hit up the MBS API so the user gets necessary privileges and emails
  
    # Do some sanity checks
    if params[:key].nil? || params[:user_id].nil?
      flash[:error] = 'You must provide both the Share Code and your email address.'
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end
    
    user = User.find(params[:user_id])
    
    unless user
      flash[:error] = 'Please login - user not found.'
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end
    
    share_code = ShareCode.where(:key => params[:key]).first

    # Does code exist?
    if share_code.nil?
      flash[:error] = 'That Share Code is invalid. Please check that you typed it correctly.'
      redirect_to :action => :redeem,
                  :mbs_share_code => params[:key],
                  :email => user.email,
                  :lightbox => params[:lightbox]
      return false
    end
    
    if share_code.redeemed
      flash[:error] = 'That Share Code has already been redeemed!'
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end    
    
    # Check if the share code has expired
    if share_code.expired?
      flash[:error] = 'That Share Code has expired.'
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end
        
    share_code.redeemed = true
    share_code.user = user
    priv_success = apply_privileges( share_code ) # Currently returns LSS ID or false
    
    if priv_success
      unless share_code.save
        redirect_to :action => :redeem,
                    :mbs_share_code => params[:key],
                    :email => user.email,
                    :lightbox => params[:lightbox]
        return false
      else
        flash[:notice] = 'Code redeemed! Check your email for instructions on accessing your new privileges.'
      end
    else
      flash[:error] = 'Oops, try inputting the code again.'
      redirect_to :action => :redeem,
                  :mbs_share_code => params[:key],
                  :email => user.email,
                  :lightbox => params[:lightbox]
      return false
    end
    
    # Successo
    # NOTE: I am assuming here that the share code is LSS and therefore has a band ID.
    # Once different share code types exist, we must change this redirection behavior.
    redirect_to :controller => 'live_stream_series',
                :action => 'by_band',
                :id => LiveStreamSeries.find(priv_success).band.id,
                :lightbox => params[:lightbox]
    return true
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
  

  private
  
  def apply_privileges (share_code)
  # Takes a share_code object, which must have a key and a user associated with it.
  # Returns false on failure, or LSS ID / true on success.

    if share_code.nil? || share_code.key.nil? || share_code.user.nil?
      return false
    end

    code_type = share_code.key[0..2]

    case code_type
      when 'LSS'
        unless lss = LiveStreamSeries.find(share_code.key[3..8])
          return false
        end
        logger.info 'LSS permissions about to be applied for LSS ' + lss.id.to_s
        unless MBS_API.change_stream_permission( { :api_key => OUR_MBS_API_KEY,
                                                   :hash => OUR_MBS_API_HASH,
                                                   :api_version => '.1',
                                                   :email => share_code.user.email,
                                                   :stream_series => lss.id,
                                                   :can_view => 1,
                                                   :can_chat => 1,
                                                   :can_listen => 1 } )
          return false
        end
      else
        logger.info 'Non-LSS code'
    end

    # Apply shares
    share_amount = share_code.share_code_group.share_amount
    if share_amount && share_amount != 0
      ShareLedgerEntry.create( :user_id => share_code.user.id,
                               :band_id => lss.band.id,
                               :adjustment => share_amount,
                               :description => 'share_code ' + share_code.id.to_s
                       )
    end

    return (lss) ? lss.id : true
  end
  
end

