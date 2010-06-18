class ShareLedgerEntry < ActiveRecord::Base
  #IMPORTANT
  #The adjustment in the ledger entry is seen as the number of shares granted TO the USER FOR the BAND.  Band's can never have shares in fans.  So if the number is positive, that means the users shares in the band will go UP.  If the number is negative, the users shares in the band will go DOWN.
  belongs_to :user
  belongs_to :band
  
  after_save :update_share_total
  
  
  
private
  def update_share_total
    #Does a share_total entry exist for this user and band combo?
    share_total = ShareTotal.where(:user_id => self.user_id, :band_id => self.band_id).first
    unless ( share_total )
      share_total = ShareTotal.create(:user_id => self.user_id,
                                      :band_id => self.band_id,
                                      :gross => 0,
                                      :net => 0 )
    end
    
    total_query = ShareLedgerEntry.where(:user_id => self.user_id, :band_id => self.band_id)
    share_total.net = total_query.sum(:adjustment)
    share_total.gross = total_query.where('adjustment > 0').sum(:adjustment)
    return share_total.save!
  end
  
end
