class ShareTotalsController < ApplicationController
  before_filter :authorize_api_access, :if => :api_call?, :only => [:show]
  before_filter :get_share_total_for_api, :if => :api_call?, :only => [:show]
  respond_to :json, :xml
  
  def show
    @share_total ||= ShareTotal.find(params[:share_total_id])
    respond_with(@share_total) do |format|
      format.xml {render :xml => [@share_total.to_xml, @share_total.band.to_xml, @share_total.user.api_attributes.to_xml]}
    end
  end
  
  private
  def get_share_total_for_api
    @user = User.find_by_email(params[:user_email])
    @band = Band.find_by_name(params[:band_name])
    if @user && @band
      @share_total = ShareTotal.find_by_user_id_and_band_id(@user.id, @band.id)
    else
      return false
    end
  end
end