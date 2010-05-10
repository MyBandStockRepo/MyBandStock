class ApiUsersController < ApplicationController
  # GET /api_users
  # GET /api_users.xml
  def index
    @api_users = ApiUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @api_users }
    end
  end

  # GET /api_users/1
  # GET /api_users/1.xml
  def show
    @api_user = ApiUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @api_user }
    end
  end

  # GET /api_users/new
  # GET /api_users/new.xml
  def new
    @api_user = ApiUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @api_user }
    end
  end

  # GET /api_users/1/edit
  def edit
    @api_user = ApiUser.find(params[:id])
  end

  # POST /api_users
  # POST /api_users.xml
  def create
    @api_user = ApiUser.new(params[:api_user])

    respond_to do |format|
      if @api_user.save
        format.html { redirect_to(@api_user, :notice => 'Api user was successfully created.') }
        format.xml  { render :xml => @api_user, :status => :created, :location => @api_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @api_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /api_users/1
  # PUT /api_users/1.xml
  def update
    @api_user = ApiUser.find(params[:id])

    respond_to do |format|
      if @api_user.update_attributes(params[:api_user])
        format.html { redirect_to(@api_user, :notice => 'Api user was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @api_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /api_users/1
  # DELETE /api_users/1.xml
  def destroy
    @api_user = ApiUser.find(params[:id])
    @api_user.destroy

    respond_to do |format|
      format.html { redirect_to(api_users_url) }
      format.xml  { head :ok }
    end
  end
end
