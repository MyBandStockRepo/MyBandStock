module FansHelper
  def get_band_name_for_url(bandname)
    bandname.downcase!
    band_name = bandname.gsub(' ', '-').downcase
    return band_name
  end
  
  def get_band_name_titlelized(bandname)
    band_name = bandname.split(' ').collect {|word| word.capitalize}.join(" ")
    return band_name
  end
end
