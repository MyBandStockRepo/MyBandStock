class LevelsController < ApplicationController
  before_filter :get_band
  before_filter :get_level, :except => [:index, :new, :create]
  before_filter :restrict_non_admin, :except => [:index, :show]
  def index
    @band = Band.find(params[:band_id])
    @levels = @band.levels
  end
  
  def new
    @level = @band.levels.build
    @user = current_user
  end

  def edit
    
  end

  def show
  end
  def create
    @level = @band.levels.build(params[:level])
    if @level.save
      redirect_to new_level_reward_path(@level)
      flash[:notice] = "Level Created! Would you like to add rewards for this level?"
    else
      render :new
    end
  end
  def update
    
  end
  def destroy
    if @level.destroy
      redirect_to session[:last_clean_url]
      flash[:notice] = "Level successfully deleted"
    else
      render :new
    end
  end
  
private
  def get_level
    @level = Level.includes(:rewards).find(params[:id])
  end
  def get_band
    @band = Band.find(params[:band_id]) if params[:band_id]
  end
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
