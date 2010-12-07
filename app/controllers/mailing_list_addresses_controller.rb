class MailingListAddressesController < ApplicationController
  before_filter :authenticated?, :except => [:create]
  before_filter :user_has_site_admin, :except => [:create]
  protect_from_forgery :only => [:create, :update]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new]
  layout 'root-layout'


  # GET /mailing_list_addresses
  # GET /mailing_list_addresses.xml
  def index
    @mailing_list_addresses = MailingListAddress.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mailing_list_addresses }
    end
  end

  # GET /mailing_list_addresses/1
  # GET /mailing_list_addresses/1.xml
  def show
    @mailing_list_address = MailingListAddress.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mailing_list_address }
    end
  end

  # GET /mailing_list_addresses/new
  # GET /mailing_list_addresses/new.xml
  def new
    @mailing_list_address = MailingListAddress.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mailing_list_address }
    end
  end

  # GET /mailing_list_addresses/1/edit
  def edit
    @mailing_list_address = MailingListAddress.find(params[:id])
  end

  # POST /mailing_list_addresses
  # POST /mailing_list_addresses.xml
  def create
    @mailing_list_address = MailingListAddress.new(params[:mailing_list_address])
    if @mailing_list_address && @mailing_list_address.email
      @mailing_list_address.email = @mailing_list_address.email.downcase
    end
    if @mailing_list_address.save
      flash[:notice] = "You will be notified at #{@mailing_list_address.email} with updates."
      redirect_to root_path      
      return true
    else
      error_message = "There was an error while trying to add you to the mailing list."
      if @mailing_list_address.errors[:email]
        error_message = "The entered email address "
        err_count = 0
        for e in @mailing_list_address.errors[:email]
          if err_count = 0
            error_message = error_message + " #{e}"
          else
            error_message = error_message + ", #{e}"
          end
          err_count += 1
        end
      end
      flash[:error] = error_message
      redirect_to root_path
      return false
    end

  end

  # PUT /mailing_list_addresses/1
  # PUT /mailing_list_addresses/1.xml
  def update
    @mailing_list_address = MailingListAddress.find(params[:id])

    respond_to do |format|
      if @mailing_list_address.update_attributes(params[:mailing_list_address])
        format.html { redirect_to(@mailing_list_address, :notice => 'Mailing list address was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mailing_list_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mailing_list_addresses/1
  # DELETE /mailing_list_addresses/1.xml
  def destroy
    @mailing_list_address = MailingListAddress.find(params[:id])
    @mailing_list_address.destroy

    respond_to do |format|
      format.html { redirect_to(mailing_list_addresses_url) }
      format.xml  { head :ok }
    end
  end
end
