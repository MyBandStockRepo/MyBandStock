class State < ActiveRecord::Base
   
   acts_as_dropdown :text => "abbreviation", :order => "name DESC"
   belongs_to :country

   validates_uniqueness_of :name
end
