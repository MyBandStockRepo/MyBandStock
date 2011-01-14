class RewardsController < ApplicationController
  before_filter :get_level
  before_filter :get_reward, :except => [:index, :new, :create]
  before_filter :restrict_non_admin, :except => [:index, :show]
  def new
    @reward = @level.rewards.build
  end
  def create
    @reward = @level.rewards.build(params[:reward])
    if @reward.save
      redirect_to new_level_reward_path(@level)
      flash[:notice] = "New Reward Added!"
    else
      render :new
    end
  end

  def edit
  end
  def update
    if @reward.update_attributes(params[:reward])
      redirect_to edit_level_reward_path(@level)
      flash[:notice]
    else
      render :new
    end
  end

  def show
  end

  def index
    @rewards = @level.rewards
  end
  def destroy
    if @reward.destroy
      redirect_to session[:last_clean_url]
      flash[:notice] = "Reward successfully deleted"
    else
      render :new
    end
  end
private
  def get_reward
    @reward = Reward.find(params[:id])
  end
  def get_level
    @level = Level.find(params[:level_id])
  end
  def restrict_non_admin
    unless logged_in? && is_site_admin_or_current_band_admin?(@level.band_id)
      if logged_in? 
        redirect_to "/me/control_panel"
      else
        redirect_to "/login"
      end
    end
  end
end
