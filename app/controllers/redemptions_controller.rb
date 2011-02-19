class RedemptionsController < ApplicationController
  before_filter :restrict_non_admin, :only => [:index, :update]
  def create
    @reward = Reward.find(params[:reward_id])
    @redemption = @reward.redemptions.build(params[:redemption])
    @redemption.user_id = current_user.id
    if @redemption.save
      redirect_to level_reward_path(@reward.level, @reward) and return
      flash[:notice] = "Your order has been sent, you'll receive a confirmation email shortly"
    else
      redirect_to level_reward_path(@reward.level, @reward) and return
      flash[:notice] = "Something has gone wrong, please try again or contact us if the problem persists."
    end
  end
  def index
    if params[:band_id]
      @redemptions = Band.find(params[:band_id]).redemptions
    else
      @redemptions = Redemption.order("created_at DESC")
    end
  end
  def update
    @redemption = Redemption.find(params[:id])
    if @redemption.update_attributes(params[:redemption])
      redirect_to :action => "index", :band_id => params[:band_id] and return
      flash[:notice] = "You have updated the redemption record successfully"
    else
      redirect_to :action => "index", :band_id => params[:band_id] and return
    end
  end
private
  def restrict_non_admin
    unless logged_in? && is_site_admin_or_current_band_admin?
      if logged_in? 
        redirect_to "/me/control_panel"
      else
        redirect_to "/login"
      end
    end
  end
end
