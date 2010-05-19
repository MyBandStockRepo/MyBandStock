# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
# To completely start anew:
#  rake db:migrate VERSION=0; rake db:migrate; rake db:seed --trace

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
#create some test bands

b_amp = Band.create(  :name => 'After Midnight Project',
                  :short_name => 'amp',
                  :country_id => 232,
                  :zipcode => '90001',
                  :city => 'LA',
                  :bio => 'After Midnight Project began in 2004 in Los Angeles, California. They are known for their energetic live shows, extensive touring, and close connection to fans. With the release of their EP, The Becoming, in 2007, they caught the attention of Universal Motown and were signed.'
        )
b_dos = Band.create(  :name => 'The Dosimeters',
                  :short_name => 'the_dosimeters',
                  :country_id => 232,
                  :zipcode => '48116',
                  :city => 'Brighton')
b_flo = Band.create(  :name => 'Flobots',
                  :short_name => 'flobots',
                  :country_id => 232,
                  :zipcode => '80201',
                  :city => 'Denver')
#make user-band associations
jm.associations.create(:band_id => b_amp.id, :name => 'admin')
jm.associations.create(:band_id => b_flo.id, :name => 'admin')
jm.associations.create(:band_id => b_dos.id, :name => 'admin')

adminUser.associations.create(:band_id => b_amp.id, :name => 'admin')
adminUser.associations.create(:band_id => b_flo.id, :name => 'admin')
adminUser.associations.create(:band_id => b_dos.id, :name => 'admin')


#create some LSSs
lss_amp = b_amp.live_stream_series.create(:title => 'Warped Tour Twenty Ten',:starts_at => 1.hour.from_now, :ends_at => 1.year.from_now)
lss_amp2 = b_amp.live_stream_series.create(:title => 'Summer tour',:starts_at => 1.hour.from_now, :ends_at => 1.year.from_now)
lss_dos = b_dos.live_stream_series.create(:title => 'ballet show',:starts_at => 1.hour.from_now, :ends_at => 1.year.from_now)

#create some StreamAPI streams (fake of course)
layoutPath = '/themes/100/000/866/4/theme_880e70c2-6377-11df-897e-45bad36ccbb1.xml'
skinPath = '/themes/100/000/866/4/skin_880e70c2-6377-11df-897e-45bad36ccbb1.xml'
lss_dos.streamapi_streams.create( :private_hostid => 123,
                              :public_hostid => 123,
                              :title => 'act 1',
                              :starts_at => 1.weeks.from_now,
                              :ends_at => (1.weeks.from_now + 2.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_dos.id )
                              
lss_dos.streamapi_streams.create( :private_hostid => 1234,
                              :public_hostid => 1234,
                              :title => 'act 2',
                              :starts_at => 2.weeks.from_now,
                              :ends_at => (2.weeks.from_now + 3.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_dos.id )

lss_dos.streamapi_streams.create( :private_hostid => 12345,
                              :public_hostid => 12345,
                              :title => 'act 3, the COOOLEST ACT',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_dos.id )


lss_amp.streamapi_streams.create(
                              :private_hostid => 123456,
                              :public_hostid => 123456,
                              :title => 'Home Depot Center - Carson, CA',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_amp.id )
lss_amp.streamapi_streams.create(
                              :private_hostid => 1234567,
                              :public_hostid => 1234567,
                              :title => 'Shoreline Amphitheatre - Mountain View, CA',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_amp.id )
lss_amp.streamapi_streams.create(
                              :private_hostid => 12345678,
                              :public_hostid => 12345678,
                              :title => 'Cricket Pavilion - Phoenix, AZ',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_amp.id )
lss_amp.streamapi_streams.create(
                              :private_hostid => 123456789,
                              :public_hostid => 123456789,
                              :title => 'AT&T Center - San Antonio, TX',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_amp.id )

lss_amp2.streamapi_streams.create(
                              :private_hostid => 01,
                              :public_hostid => 01,
                              :title => 'Comerica Park - Detroit, MI',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_amp.id )
lss_amp2.streamapi_streams.create(
                              :private_hostid => 012,
                              :public_hostid => 012,
                              :title => 'Danny\'s Bar Mitzvah - Brighton, MI',
                              :starts_at => 3.weeks.from_now,
                              :ends_at => (3.weeks.from_now + 4.hours),
                              :layout_path => layoutPath,
                              :skin_path => skinPath,
                              :public => false,
                              :band_id => b_amp.id )


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


#adminUser = User.create(:first_name => 'admin', :last_name => 'user', :password => 'fd7013a96f6210e7aa475bed9f422f70ffefa5932e5e05a6aea77840929edce2', :email => 'mbstech@mybandstock.com', :status => 'active')
#r = User.find(adminUser.id).roles.create(:name => 'site_admin')
#roles = Role.create(:name => 'staff')
