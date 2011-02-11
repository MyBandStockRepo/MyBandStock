class RedemptionsController < ApplicationController
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
end
