require "will_paginate"

class StaticsController < ApplicationController
  
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

end
