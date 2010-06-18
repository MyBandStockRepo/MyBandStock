class DashboardController < ApplicationController
  before_filter :authenticated?
  before_filter :user_has_site_admin  

  def home
    @bands = PledgedBand.all(:order => 'pledges_count DESC', :include => [:pledges, :fans])
    respond_to do |format|
      format.html
      format.xml { render :xml => @bands }
      format.xls { send_data @bands.to_xls }
    end
  end
  
  def admin_new_entry
  end
  
  def admin_new_entry_create
    #Finds or Creates NEW Pledged Band
    pledged_band = PledgedBand.find_or_create_by_name(params[:admin][:band_name])
    fan = Fan.create(:first_name => params[:admin][:first_name], :last_name => params[:admin][:last_name], :email => params[:admin][:email])
    Pledge.create(:fan_id => fan.id, :pledged_band_id => pledged_band.id)
    flash[:notice] = 'Pledge was successfully created.'
    redirect_to admin_new_entry_url
  end
  
  
  def home_refine_band
    band = params[:filter][:band_name]
    @band = PledgedBand.find_by_name(band, :include => [:pledges, :fans])
    render :action => 'home'
  end
    
  #EXPORT TO EXCEL METHODS ALL AND BY BAND
  def export_all
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="report.xls"'
    headers['Cache-Control'] = ''
    #SQL QUERY INTO XLS FORMAT
    @bands = PledgedBand.find_by_sql "SELECT pledged_bands.name, pledged_bands.pledges_count, fans.first_name, fans.last_name, fans.email, pledges.created_at FROM pledged_bands LEFT JOIN pledges ON pledged_bands.id = pledges.pledged_band_id LEFT JOIN fans on pledges.fan_id = fans.id"
  end
  
  def export_by_band
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="report.xls"'
    headers['Cache-Control'] = ''
    #SQL QUERY INTO XLS FORMAT
    band_name = params[:filter][:band_name]
    @bands = PledgedBand.find_by_sql("SELECT Pledged_Bands.name, Pledged_Bands.pledges_count, Fans.first_name, Fans.last_name, Fans.email, Pledges.created_at FROM Pledged_Bands LEFT JOIN PLEDGES ON Pledged_Bands.id = Pledges.pledged_band_id LEFT JOIN Fans on pledges.fan_id = fans.id WHERE Pledged_Bands.name = '#{band_name}'")
  end

end
