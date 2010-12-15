task :test_ruby_prof => :environment do
  require 'ruby-prof'

   # Profile the code
   RubyProf.start
    Authentication.create(:user_id => 1, :provider => "Twitter")
   results = RubyProf.stop

   File.open "#{RAILS_ROOT}/tmp/profile-graph.html", 'w' do |file|
     RubyProf::GraphHtmlPrinter.new(results).print(file)
   end
end