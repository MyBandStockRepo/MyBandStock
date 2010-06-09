class AssociationsController < ApplicationController
  
  before_filter :authenticated?
  before_filter :user_is_admin_of_a_band?
  
  protect_from_forgery :only => [:create, :update]
  skip_filter :update_last_location, :only => [:new, :create, :update, :index, :show]
  
  
def index
  redirect_to session[:last_clean_url]
end


def show
  redirect_to session[:last_clean_url]
end



def new
  @association = Association.new()
  respond_to do |format|
      format.html {
                    @users = User.all
                    @bands = Band.find_all_by_id(User.find(session[:user_id]).associations.reject{|a| a.name == "fan"}.collect{|a| a.band_id}.uniq, :order => "bands.id desc") 
                  }
      format.js
      format.xml
    end
end

def create
  @association = Association.new(:band_id => params[:association][:band_id], :name => params[:association][:name])
  unless ( !@association.nil? ) && ( User.find(session[:user_id]).has_band_admin(@association.band_id) )
    unless User.find(session[:user_id]).has_site_admin
      redirect_to session[:last_clean_url]
      return false
    end
  end
  
  new_user_email = params[:association][:user_id] # Email sent through user_id field
  
  if ( @user = User.find_by_email(new_user_email) )
    @association.user_id =  @user.id
    @user_email = @user.email
    @association.save 
    success = true
  else
    success = false
    @user_email = new_user_email
  end
  
  

  respond_to do |format|
    format.html {
                   if success
                    flash[:notice] = 'Association was successfully created.'

                    redirect_to session[:last_clean_ur] || root_path
                  else
                    @users = User.all
                    @bands = Band.find_all_by_id(User.find(session[:user_id]).associations.reject{|a| a.name == "fan"}.collect{|a| a.band_id}.uniq, :order => "bands.id desc") 
                    render :action => :new
                  end
                }
    format.js   {
                  if success
                    @fresh_association = Association.new
                    @fresh_association.band_id = @association.band_id
                  else
                    flash[:notice] = 'Email address not found in our database.  Email address must match a user in our database.  Ask the person you are attempting to add what email address they used when they registered at MyBandStock.'
                    render :update do |page|
                      page.redirect_to :controller => 'associations', :action => 'new'
                    end
                    return false
                  end
                      
                  #let the rjs render
                }
    format.xml
    end
end 


def edit
  @association = Association.find(params[:id])
  unless ( !@association.nil? ) && ( User.find(session[:user_id]).has_band_admin(@association.band_id) )
    redirect_to session[:last_clean_url]
    return false
  end
  
  @user_email = @association.user.email

  respond_to do |format|
    format.html 
    format.js   
    format.xml
  end
  
end


def update
  @association = Association.find(params[:id])
  unless ( !@association.nil? ) && ( User.find(session[:user_id]).has_band_admin(@association.band_id) )
    redirect_to session[:last_clean_url]
    return false
  end
  
  user_email = params[:association][:email]
  
  if ( @user = User.find_by_email(user_email) )
    @association.user_id =  @user.id
    @user_email = @user.email
    success = true
  else
    success = false
    @user_email = @association.user.email
  end
  
  @association.name = params[:association][:name]
  @association.save
  
  respond_to do |format|
    format.html {
                  if success
                    flash[:notice] = "Association updated."
                    redirect_to session[:last_clean_url]
                  else
                    flash[:notice] = 'Email address not found in our database.  Email address must match a user in our database.  Ask the person you are attempting to add what email address they used when they registered at MyBandStock.'
                    render :controller => 'associations', :action => 'edit'
                  end
                }
    format.js   {
                  @fresh_association = Association.new
                  @fresh_association.band_id = @association.band_id
                  #let the rjs render
                }
    format.xml
  end

end




def destroy
  @association = Association.find(params[:id])
  unless ( !@association.nil? ) && ( User.find(session[:user_id]).has_band_admin(@association.band_id) )
    redirect_to session[:last_clean_url]
    return false
  end
  
  if ((@association.name == 'admin') && (@association.band.associations.find_all_by_name('admin').size == 1) ) 
    flash[:notice] = 'Each band must have at least one admin, so you cannot delete the last one.  If you wish to delete yourself, please add someone else as an admin then have them remove you.'
    redirect_to session[:last_clean_url]
    return false
  end
  
  @old_association_id = @association.id
  old_association_band_id = @association.band_id
  
  @association.destroy
  
  respond_to do |format|
    format.html {
                  redirect_to session[:last_clean_url]
                }  
    format.js   {
                  @fresh_association = Association.new
                  @fresh_association.band_id = old_association_band_id
                  #let the rjs render
                }
    format.xml
  end
  
end




#end the controller
end
