Factory.sequence :name do |n|
  "#{n} Long Band"
end
Factory.sequence :short_name do |n|
  "#{n}_short_band"
end
Factory.define :band do |band|
  band.name           {Factory.next :name}
  band.country        {Factory :country}
  band.zipcode        {02035}
  band.city           {"Foxboro"}
  band.short_name     {Factory.next :short_name}
  band.secret_token   {12345}
end