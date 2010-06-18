require "will_paginate"

class StaticsController < ApplicationController
  
  #RENDER ABOUT WHEN CLICKING ABOUT IN HOMEPAGE
  def about
    render :action => 'about' 
  end

  #RENDER PLEDGED BANDS WHEN CLICKING BANDS IN HOMEPAGE
  def pbands
    #@pbands = PledgedBand.find(:all, :order => 'pledges_count DESC')
    @pbands = PledgedBand.paginate :page => params[:page], :order => 'pledges_count DESC'
    render :action => 'pbands'
  end

  #RENDER FAQ WHEN CLICKING FAQ IN HOMEPAGE
  def faq
    render :action => 'faq'
  end

end
