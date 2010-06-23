require 'MBS_API'

class ShareCodesController < ApplicationController
  before_filter :authenticated?, :except => [:redeem, :redeem_post, :complete_redemption]
  before_filter :user_has_site_admin, :except => [:redeem, :redeem_post, :complete_redemption]
  protect_from_forgery :only => [:redeem_post, :create, :update]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new, :redeem, :complete_redemption]

  def redeem
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
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end
    
    # If the user exists, we send him to complete_redemption
    # If the user does not exist, we send him to create an account
    if User.where(:email => params[:email]).first
      redirect_to :action => :complete_redemption, :key => params[:share_code][:key], :email => params[:email]
      return true
    else
      redirect_to new_user_path(), :lightbox => params[:lightbox],
                                   :after_create_redirect => url_for({
                                                                    :controller => 'share_codes',
                                                                    :action => 'complete_redemption'
                                                                  }),
                                   :user => { :email => params[:email] }
                               
      return true
    end

  end

  def complete_redemption
  # The user came here if he already existed in the system or if he just registered.
  # 1. Invalidate code
  # 2. Parse the code to determine which privileges should be granted
  # 3. Hit up the MBS API so the user gets necessary privileges and emails
  
    # Do some sanity checks
    if params[:key].nil? || params[:email].nil?
      flash[:error] = 'You must provide both the Share Code and your email address.'
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end
    
    share_code = ShareCode.where(:key => params[:key]).first

    # Does code exist?
    if share_code.nil?
      flash[:error] = 'That Share Code is invalid. Please check that you typed it correctly.'
      redirect_to :action => :redeem,
                  :mbs_share_code => params[:key],
                  :email => params[:email],
                  :lightbox => params[:lightbox]
      return false
    end
    
    share_code.redeemed = true
    share_code.user = User.where(:email => params[:email]).first
    priv_success = apply_privileges( share_code )
    
    if priv_success
      unless share_code.save
        redirect_to :action => :redeem,
                    :mbs_share_code => params[:key],
                    :email => params[:email],
                    :lightbox => params[:lightbox]
        return false
      else
        flash[:notice] = 'Code redeemed!'
      end
    else
      flash[:error] = 'Oops, try inputting the code again.'
      redirect_to :action => :redeem,
                  :mbs_share_code => params[:key],
                  :email => params[:email],
                  :lightbox => params[:lightbox]
      return false
    end
    
    render :nothing => true
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

    if share_code.nil? || share_code.key.nil? || share_code.user.nil?
      return false
    end

    code_type = share_code.key[0..2]

    case share_code.key[0..2]
    when 'LSS'
      unless lss = LiveStreamSeries.find(share_code.key[3..8])
        return false
      end
      logger.info 'LSS permissions about to be applied to ' + lss.id.to_s
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
      share_amount = share_code.share_code_group.share_amount
      if share_amount && share_amount != 0
        ShareLedgerEntry.create( :user_id => share_code.user.id,
                                 :band_id => lss.band.id,
                                 :adjustment => share_code.share_amount,
                                 :description => 'share_code ' + share_code.id.to_s
                         )
      end
    else
      logger.info 'Non-LSS code'
    end
    
    
    return true
  end
  
end

