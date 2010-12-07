require "will_paginate"

class StaticsController < ApplicationController

  def splash_page
    render :layout => false
  end

  def broadcast_faq
    
  end

  def status_404
    @requested_page = params[:requested_page]
    render :status => 404
  end
  
  #RENDER ABOUT WHEN CLICKING ABOUT IN HOMEPAGE
  def about
    render :action => 'about' 
  end

  #RENDER PLEDGED BANDS WHEN CLICKING BANDS IN HOMEPAGE
  def pbands
    if params[:page].nil?
      @pbands = PledgedBand.order('pledges_count DESC').all.paginate(:page => nil)
    else
      @pbands = PledgedBand.order('pledges_count DESC').all.paginate(:page => params[:page])
    end
    render :action => 'pbands'
  end

  #RENDER FAQ WHEN CLICKING FAQ IN HOMEPAGE
  def faq
    render :action => 'faq'
  end
  
  def support
    
  end
  
  def robots_txt
    render :file => 'public/shorturl_robots.txt', :layout => false and return
  end
  
  def favicon_ico
    #render :file => 'public/favicon.ico', :layout => false, :type => 'text/plain' and return
    send_file 'public/favicon.ico', :type => 'image/vnd.microsoft.icon', :disposition => 'inline'
    return
  end

end
