class TwitterCrawlerHashTagsController < ApplicationController
  before_filter :authenticated?
  before_filter :user_has_site_admin
  
  # GET /twitter_crawler_hash_tags
  # GET /twitter_crawler_hash_tags.xml
  def index
    @twitter_crawler_hash_tags = TwitterCrawlerHashTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @twitter_crawler_hash_tags }
    end
  end

  # GET /twitter_crawler_hash_tags/1
  # GET /twitter_crawler_hash_tags/1.xml
  def show
    @twitter_crawler_hash_tag = TwitterCrawlerHashTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @twitter_crawler_hash_tag }
    end
  end

  # GET /twitter_crawler_hash_tags/new
  # GET /twitter_crawler_hash_tags/new.xml
  def new
    @twitter_crawler_hash_tag = TwitterCrawlerHashTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @twitter_crawler_hash_tag }
    end
  end

  # GET /twitter_crawler_hash_tags/1/edit
  def edit
    @twitter_crawler_hash_tag = TwitterCrawlerHashTag.find(params[:id])
  end

  # POST /twitter_crawler_hash_tags
  # POST /twitter_crawler_hash_tags.xml
  def create
    @twitter_crawler_hash_tag = TwitterCrawlerHashTag.new(params[:twitter_crawler_hash_tag])

    respond_to do |format|
      if @twitter_crawler_hash_tag.save
        format.html { redirect_to(@twitter_crawler_hash_tag, :notice => 'Twitter crawler hash tag was successfully created.') }
        format.xml  { render :xml => @twitter_crawler_hash_tag, :status => :created, :location => @twitter_crawler_hash_tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @twitter_crawler_hash_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /twitter_crawler_hash_tags/1
  # PUT /twitter_crawler_hash_tags/1.xml
  def update
    @twitter_crawler_hash_tag = TwitterCrawlerHashTag.find(params[:id])

    respond_to do |format|
      if @twitter_crawler_hash_tag.update_attributes(params[:twitter_crawler_hash_tag])
        format.html { redirect_to(@twitter_crawler_hash_tag, :notice => 'Twitter crawler hash tag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @twitter_crawler_hash_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_crawler_hash_tags/1
  # DELETE /twitter_crawler_hash_tags/1.xml
  def destroy
    @twitter_crawler_hash_tag = TwitterCrawlerHashTag.find(params[:id])
    @twitter_crawler_hash_tag.destroy

    respond_to do |format|
      format.html { redirect_to(twitter_crawler_hash_tags_url) }
      format.xml  { head :ok }
    end
  end
end
