class TwitterUsersController < ApplicationController
	before_filter :authenticated?
	before_filter :user_has_site_admin
	protect_from_forgery :only => [:create, :update]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new]
  
  # GET /twitter_users
  # GET /twitter_users.xml
  def index
    @twitter_users = TwitterUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @twitter_users }
    end
  end

  # GET /twitter_users/1
  # GET /twitter_users/1.xml
  def show
    @twitter_user = TwitterUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @twitter_user }
    end
  end

  # GET /twitter_users/new
  # GET /twitter_users/new.xml
  def new
    @twitter_user = TwitterUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @twitter_user }
    end
  end

  # GET /twitter_users/1/edit
  def edit
    @twitter_user = TwitterUser.find(params[:id])
  end

  # POST /twitter_users
  # POST /twitter_users.xml
  def create
    @twitter_user = TwitterUser.new(params[:twitter_user])

    respond_to do |format|
      if @twitter_user.save
        format.html { redirect_to(@twitter_user, :notice => 'Twitter user was successfully created.') }
        format.xml  { render :xml => @twitter_user, :status => :created, :location => @twitter_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @twitter_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /twitter_users/1
  # PUT /twitter_users/1.xml
  def update
    @twitter_user = TwitterUser.find(params[:id])

    respond_to do |format|
      if @twitter_user.update_attributes(params[:twitter_user])
        format.html { redirect_to(@twitter_user, :notice => 'Twitter user was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @twitter_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_users/1
  # DELETE /twitter_users/1.xml
  def destroy
    @twitter_user = TwitterUser.find(params[:id])
    @twitter_user.destroy

    respond_to do |format|
      format.html { redirect_to(twitter_users_url) }
      format.xml  { head :ok }
    end
  end
end
