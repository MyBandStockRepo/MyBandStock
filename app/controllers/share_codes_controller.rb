class ShareCodesController < ApplicationController

  before_filter :user_has_site_admin, :except => [:redeem, :redeem_post]

  def redeem
    @share_code = ShareCode.new
    @share_code.key = params[:mbs_share_code]
    if session[:user_id]
      @email = User.find(session[:user_id]).email
    end
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
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
      return false
    end
    
    # Check if the share code has already been redeemed
    if ShareCode.where(:key => params[:share_code][:key]).first
      flash[:error] = 'That Share Code has already been redeemed!'
      redirect_to :action => :redeem, :lightbox => params[:lightbox]
    end
    
    # If the user exists, we send to complete_redemption
    # If the user does not exist, we send him to create an account
    if User.where(:email => params[:share_code][:email]).first
      redirect_to :action => :complete_redemption
      return true
    else
      setUserFormActionToGoToComplete
      redirect_to new_user_path
      return true
    end
    
  end

  def complete_redemption
  # The user came here if he already existed in the system or if he just registered.
  # 1. Invalidate code
  # 2. Parse the code to determine which privileges should be granted
  # 3. Hit up the MBS API so the user gets necessary privileges and emails
  
    # Do some sanity checks

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
end
