# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#the creation tree goes as follows
#user ->
adminUser = User.create( :first_name => 'admin', 
                        :last_name => 'user', 
                        :password_confirmation => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', 
                        :password => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', 
                        :country_id => 233, 
                        :email => 'mbstech@mybandstock.com', 
                        :status => 'active',
                        :agreed_to_tos => true,
                        :agreed_to_pp => true)
                        
site_admin_role = Role.create(:name => 'site_admin')
Role.create(:name => 'staff')

#grant the admin user site_admin
adminUser.roles << site_admin_role


#create JM's stuff
jm = User.create( :first_name => 'John-Michael',
                  :last_name => 'Fischer',
                  :password => Digest::SHA2.hexdigest('test123'),
                  :password_confirmation => Digest::SHA2.hexdigest('test123'),
                  :zipcode => '48116',
                  :country_id => 233,
                  :email => 'jm@mybandstock.com',
                  :status => 'active',
                  :agreed_to_tos => true,
                  :agreed_to_pp => true)
#grant admin
jm.roles << site_admin_role
#create a band
b = Band.create(  :name => 'The Dosimeters',
                  :short_name => 'the_dosimeters',
                  :country_id => 233,
                  :zipcode => '48116',
                  :city => 'Brighton')
#make me an admin
jm.associations.create(:band_id => b.id, :name => 'admin')
#create an LSS
lss = b.live_stream_series.create(:title => 'ballet show',:starts_at => 1.hour.from_now, :ends_at => 1.year.from_now)
#create some StreamAPI streams (fake of course)
lss.streamapi_streams.create( :private_hostid => 123,
                              :public_hostid => 123,
                              :title => 'act 1',
                              :starts_at => 1.weeks.from_now,
                              :ends_at => (1.weeks.from_now + 2.hours),
                              :layout_path => 'noobs',
                              :skin_path => 'l337',
                              :public => false,
                              :band_id => b.id )
                              
lss.streamapi_streams.create( :private_hostid => 1234,
                              :public_hostid => 1234,
                              :title => 'act 2',
                              :starts_at => 2.weeks.from_now,
                              :ends_at => (2.weeks.from_now + 3.hours),
                              :layout_path => 'noobs',
                              :skin_path => 'l337',
                              :public => false,
                              :band_id => b.id )

lss.streamapi_streams.create( :private_hostid => 12345,
                              :public_hostid => 12345,
                              :title => 'act 3, the COOOLEST ACT',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => 'noobs',
                              :skin_path => 'l337',
                              :public => false,
                              :band_id => b.id )


#create Brians stuff
brian = User.create( :first_name => 'Brian',
                  :last_name => 'Jennings',
                  :password => Digest::SHA2.hexdigest('test123'),
                  :password_confirmation => Digest::SHA2.hexdigest('test123'),
                  :country_id => 233,
                  :email => 'brian@mybandstock.com',
                  :status => 'active',
                  :agreed_to_tos => true,
                  :agreed_to_pp => true)

#create Jakes stuff
jake = User.create( :first_name => 'Jake',
                  :last_name => 'Schwartz',
                  :password => Digest::SHA2.hexdigest('test123'),
                  :password_confirmation => Digest::SHA2.hexdigest('test123'),
                  :country_id => 233,
                  :email => 'jake@mybandstock.com',
                  :status => 'active',
                  :agreed_to_tos => true,
                  :agreed_to_pp => true)


adminUser = User.create(:first_name => 'admin', :last_name => 'user', :password => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', :email => 'mbstech@mybandstock.com', :status => 'active')
#r = User.find(adminUser.id).roles.create(:name => 'site_admin')
#roles = Role.create(:name => 'staff')
