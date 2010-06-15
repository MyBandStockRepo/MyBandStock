class ShortUrlsController < ApplicationController

  before_filter :authenticated?, :execept => :redirect
  before_filter :user_has_site_admin, :execept => :redirect
  
  def redirect
    unless dest = ShortUrl.where(:key => params[:key]).first
      redirect_to root_path
      return false
    end
    redirect_to dest.destination
    return true
  end

  # GET /short_urls
  # GET /short_urls.xml
  def index
    @short_urls = ShortUrl.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @short_urls }
    end
  end

  # GET /short_urls/1
  # GET /short_urls/1.xml
  def show
    @short_url = ShortUrl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @short_url }
    end
  end

  # GET /short_urls/new
  # GET /short_urls/new.xml
  def new
    @short_url = ShortUrl.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @short_url }
    end
  end

  # GET /short_urls/1/edit
  def edit
    @short_url = ShortUrl.find(params[:id])
  end

  # POST /short_urls
  # POST /short_urls.xml
  def create
    @short_url = ShortUrl.new(params[:short_url])

    respond_to do |format|
      if @short_url.save
        format.html { redirect_to(@short_url, :notice => 'Short url was successfully created.') }
        format.xml  { render :xml => @short_url, :status => :created, :location => @short_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @short_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /short_urls/1
  # PUT /short_urls/1.xml
  def update
    @short_url = ShortUrl.find(params[:id])

    respond_to do |format|
      if @short_url.update_attributes(params[:short_url])
        format.html { redirect_to(@short_url, :notice => 'Short url was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @short_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /short_urls/1
  # DELETE /short_urls/1.xml
  def destroy
    @short_url = ShortUrl.find(params[:id])
    @short_url.destroy

    respond_to do |format|
      format.html { redirect_to(short_urls_url) }
      format.xml  { head :ok }
    end
  end
end
