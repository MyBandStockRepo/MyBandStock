class ShareLedgerEntry < ActiveRecord::Base
  #IMPORTANT
  #The adjustment in the ledger entry is seen as the number of shares granted TO the USER FOR the BAND.  Band's can never have shares in fans.  So if the number is positive, that means the users shares in the band will go UP.  If the number is negative, the users shares in the band will go DOWN.
  belongs_to :user
  belongs_to :band
  belongs_to :transaction
  
  after_save :update_share_total
  
  
  
private
  def update_share_total
    #Does a share_total entry exist for this user and band combo?
    share_total = ShareTotal.where(:user_id => self.user_id, :band_id => self.band_id).first
    unless ( share_total )
      
      band = self.band
      low_level = band.levels.order(:points).first
      
      
      #create the entry for 0 shares, then update the rank
      share_total = ShareTotal.create(:user_id => self.user_id,
                                      :band_id => self.band_id,
                                      :gross => 0,
                                      :net => 0,
                                      :level_id => low_level.id
                                      )
      
      #set the rank (+1 because starts at 0)
      rank = band.get_shareholder_list_in_order.index(share_total)+1
      share_total.last_rank = rank
      share_total.current_rank = rank
    end
    
    total_query = ShareLedgerEntry.where(:user_id => self.user_id, :band_id => self.band_id)
    share_total.net = total_query.sum(:adjustment)
    share_total.gross = total_query.where('adjustment > 0').sum(:adjustment)
    
    success = share_total.save!
#    logger.info 'SUCCESS? '+success.to_s

    #commented out because not fully tested yet
    share_total.update_user_ranks

    
    return success
  end
  
  
  

  
end
