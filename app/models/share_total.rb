class ShareTotal < ActiveRecord::Base
  #IMPORTANT
  #It's always important to remember that users are the only ones granted shares. So whenever you see that some 'share' type object has both a user and a band; interpret that as, "The user has X shares in band Y".
  #The 'net' share total accounts for both positive and negative account adjustments
  #The 'gross' share total accounts only for positive account adjustments
  belongs_to :user
  belongs_to :band
  
  def initialize_ranks(band_id=nil)
    if band_id.nil?
      all_bands = Band.all
    else
      all_bands = Band.find(band_id)
    end
    
    for band in all_bands
      share_total_list = band.get_shareholder_list_in_order
      rank = 1
      for share_total in share_total_list
        share_total.last_rank = rank
        share_total.current_rank = rank
        share_total.save
        rank += 1
      end
    end
  end  
  
end
