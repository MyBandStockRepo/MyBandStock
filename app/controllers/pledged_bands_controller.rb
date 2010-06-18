class PledgedBandsController < ApplicationController
  
  # GET /pledged_bands
  # GET /pledged_bands.xml
  def index
    @pledged_bands = PledgedBand.find(:all, :conditions => ['name LIKE ?', "%#{params[:q]}%"], :order => "name", :include => "pledges")    
    
    respond_to do |format|
      format.js   { render :layout => false }
    end
    
  end
end
