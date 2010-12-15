class ProfileAction 
  require 'ruby-prof'
  def self.profile(code_to_test, file_prefix="profile")
     # Profile the code
     RubyProf.start
     # Authentication.create(:user_id => 1, :provider => "Twitter")
     code_to_test
     results = RubyProf.stop
     File.open "#{RAILS_ROOT}/tmp/#{file_prefix}-graph.html", 'w' do |file|
       RubyProf::GraphHtmlPrinter.new(results).print(file)
     end
     File.open "#{RAILS_ROOT}/tmp/#{file_prefix}-flat.txt", 'w' do |file|
       RubyProf::FlatPrinter.new(results).print(file)
     end
     File.open "#{RAILS_ROOT}/tmp/#{file_prefix}-tree.prof", 'w' do |file|
       RubyProf::CallTreePrinter.new(results).print(file)
     end
  end
end