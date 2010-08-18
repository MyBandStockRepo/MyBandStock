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
  
  def update_user_ranks
    band = self.band    
    share_totals = band.get_shareholder_list_in_order
    
    #add +1 since array index starts at 0
    calculated_rank = share_totals.index(self)+1

    return false if calculated_rank.blank?
    
    #copy current rank to last rank
    self.last_rank = self.current_rank
    self.current_rank = calculated_rank
    
    if self.last_rank > self.current_rank
      #moved up the list ie. 5 to 3
      #incrament others in-between
      for i in (self.current_rank+1..self.last_rank)
        share_totals[i].last_rank = share_totals[i].current_rank
        share_totals[i].current_rank = share_totals[i].current_rank + 1
        share_totals[i].save
      end
    elsif self.last_rank < self.current_rank
      #moved down the list ie. 3 to 5
      #decrament others in-between
      for i in (self.last_rank..self.current_rank-1)
        share_totals[i].last_rank = share_totals[i].current_rank
        share_totals[i].current_rank = share_totals[i].current_rank - 1
        share_totals[i].save
      end      
    end
    
    return share_total.save!
  end
  

  
end
