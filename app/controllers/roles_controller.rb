class RolesController < ApplicationController

  before_filter :authenticated?
  before_filter :user_has_site_admin
  skip_filter :update_last_location, :except => [:index]
  protect_from_forgery :only => [:create, :update]
  skip_filter :update_last_location, :except => [:index, :show, :edit, :new, :toggle_user_role]  
  
  def toggle_user_role
    unless ( (@user = User.find_by_email(params[:role][:user_email].to_s.strip)) && (@role = Role.find(params[:role][:id])))
      redirect_to session[:last_clean_url]
      return false
    end


		@siteadmins = User.includes(:roles).where('roles.name' => 'site_admin')

		if ( @role.name == 'site_admin' && @siteadmins.count > 1 ) || ( @siteadmins.count == 1 && @siteadmins.first.email != @user.email )
	    @user.toggle_role(@role.id)
  	end  
    
    respond_to do |format|
        format.html {
                      flash[:notice] = 'User role toggled.'
                      redirect_to session[:last_clean_url]
                    }
        format.js
        format.xml  { head :ok }
    end
  end
  

  def auto_complete_for_role_user_email
    unless ( (params[:role] && (email_search = params[:role][:user_email]) ) && (email_search.length >= 3) )
      render :nothing => true
      return false
    end

    @users = User.where(['email LIKE ?', "%#{email_search}%"], :limit => 15)

    respond_to do |format|
      format.html {
                    render :nothing => true
                  }
      format.js   {
                    #dont like calling render in the code but it is what it is
                    render :partial => 'roles/user_email_autocomplete', :locals => {:user_collection => @users}
                  }
      format.xml
    end
    
  end

  
  def index
    @roles = Role.find(:all, :order => ['created_at asc'])
		@users = User.all
    respond_to do |format|
        format.html
        format.js
        format.xml  { head :ok }
    end
    
  end


  def new
    @role = Role.new
    @user = User.find(session[:user_id])
    
    respond_to do |format|
        format.html
        format.js
        format.xml  { head :ok }
    end
  end


    def create
    @role = Role.new(params[:role])
    success = @role.save

    respond_to do |format|
      format.html { 
                    if success
                      flash[:notice] = 'Role created.'
                      redirect_to session[:last_clean_url]
                    else
                      @user = User.find(session[:user_id])
                      render :controller => 'roles', :action => 'new'
                    end
                  }
      format.js 
      format.xml  { head :ok }
    end
  end
  
  
  def edit
    unless ( @role = Role.find(params[:id]) )
      redirect_to session[:last_clean_url]
      return false
    end
    
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  
  def update
    unless ( @role = Role.find(params[:id]) )
      redirect_to session[:last_clean_url]
      return false
    end
    
    @role.update_attributes(params[:role])
    @role.save
    
    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  }
      format.js
      format.xml
    end
    
  end
  
  
  def show
    unless ( @role = Role.find(params[:id]) )
      redirect_to session[:last_clean_url]
      return false
    end
    
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
    
  end
  
  
  def destroy
    #site admin check included in before_filter
    unless (@role = Role.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end

    @old_role_id = @role.id
    @role.destroy

    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  } 
      format.js   #let the rjs render
      format.xml
    end
    
  end





#end controller
end

