class ShareTotal < ActiveRecord::Base
  #IMPORTANT
  #It's always important to remember that users are the only ones granted shares. So whenever you see that some 'share' type object has both a user and a band; interpret that as, "The user has X shares in band Y".
  #The 'net' share total accounts for both positive and negative account adjustments
  #The 'gross' share total accounts only for positive account adjustments
  belongs_to :user
  belongs_to :band
  belongs_to :level
  
  after_save :update_level_id  
  
  # def net
  #     self.attributes[:net] || 0
  #   end
  
  def update_level_id
    if self.level && self.level.next && self.gross >= self.level.next.points
      self.level = self.level.next
      self.save
    end
  end  
  
  def self.get_with_band_and_user_ids(band_id, user_id)
    total = joins(:user, :band).where("band_id = #{band_id} and user_id = #{user_id}").first
    total.nil? ? ShareTotal.create(:user_id => user_id, :band_id => band_id) : total
  end
  
  def self.initialize_ranks(band_id=nil)
    if band_id.nil?
      all_bands = Band.all
    else
      all_bands = Array.new().push(Band.find(band_id))
    end
    
    for band in all_bands
      share_totals = band.get_shareholder_list_in_order.collect{|item| ShareTotal.find(item.id)}
      rank = 1      
      for share_total in share_totals
        share_total.last_rank = rank
        share_total.current_rank = rank
        share_total.save
        rank += 1
      end
    end
    return true
  end  
  
  
  def update_user_ranks
    band = self.band    
    
    #share total join table
    share_totals = band.get_shareholder_list_in_order
    
    # output for testing
=begin
     puts"\n"    
    puts ' RANKS (before update) '
    puts '================================'    
    for s in share_totals
      if s.current_rank > s.last_rank
        puts s.user.first_name.to_s+"\t\t\t"+s.net.to_s+"\t\t\t"+s.current_rank.to_s+"\t\t\t"+'V'
      elsif s.current_rank < s.last_rank
        puts s.user.first_name.to_s+"\t\t\t"+s.net.to_s+"\t\t\t"+s.current_rank.to_s+"\t\t\t"+'^'
      else
        puts s.user.first_name.to_s+"\t\t\t"+s.net.to_s+"\t\t\t"+s.current_rank.to_s+"\t\t\t"+'>'
      end
    end
    puts '================================'
         puts"\n"
=end    
    
    
    
    
    
    #add +1 since array index starts at 0
    calculated_rank = share_totals.index(self)+1

    return false if calculated_rank.blank?

=begin    
    puts 'CURRENT RANK: '+self.current_rank.to_s
    puts 'LAST RANK: '+self.last_rank.to_s    
    puts 'CALCULATED RANK: '+calculated_rank.to_s        
=end
    
    #copy current rank to last rank
    self.last_rank = self.current_rank
    self.current_rank = calculated_rank
    self.save
    
    
    if self.last_rank > self.current_rank
      #moved up the list ie. 5 to 3
      #incrament others in-between
      
      #build an id list for mysql query
      id_list = '('
      #-1 to each for array position
      for i in (self.current_rank..self.last_rank-1)
        if i == self.last_rank-1
          id_list = id_list + share_totals[i].id.to_s+')'
        else
          id_list = id_list + share_totals[i].id.to_s+', '          
        end
      end
      puts 'moved up the list ie. 5 to 3'
      puts id_list
      
      
      #save the fields
#      ShareTotal.find_by_sql('UPDATE share_totals SET last_rank = share_totals.current_rank WHERE share_totals.id in'+id_list)
#      ShareTotal.find_by_sql('UPDATE share_totals SET current_rank = share_totals.current_rank + 1 WHERE share_totals.id in'+id_list)
      
      ShareTotal.update_all('last_rank = current_rank', 'id IN '+id_list.to_s)
      ShareTotal.update_all('current_rank = current_rank+1', 'id IN '+id_list.to_s)
    elsif self.last_rank < self.current_rank
      #moved down the list ie. 3 to 5
      #decrament others in-between

      #build an id list for mysql query
      id_list = '('
      #-1 to each for array position      
      for i in (self.last_rank-1..self.current_rank-2)
        if i == self.current_rank-2
          id_list = id_list + share_totals[i].id.to_s+')'
        else
          id_list = id_list + share_totals[i].id.to_s+', '          
        end
      end   
      puts 'moved down the list ie. 3 to 5'
      puts id_list

      #save the fields
#      ShareTotal.find_by_sql('UPDATE share_totals SET last_rank = share_totals.current_rank WHERE share_totals.id in'+id_list)
#      ShareTotal.find_by_sql('UPDATE share_totals SET current_rank = share_totals.current_rank - 1 WHERE share_totals.id in'+id_list)
      ShareTotal.update_all('last_rank = current_rank', 'id IN '+id_list.to_s)
      ShareTotal.update_all('current_rank = current_rank-1', 'id IN '+id_list.to_s)
=begin      
      for i in (self.last_rank..self.current_rank-1)
        share_totals[i].last_rank = share_totals[i].current_rank
        share_totals[i].current_rank = share_totals[i].current_rank - 1
        share_totals[i].save
      end      
=end
    end
    
    
=begin    
    # output for testing
     share_totals = band.get_shareholder_list_in_order
     puts"\n"
    puts ' RANKS (after update) '
    puts '================================'    
    for s in share_totals
      if s.current_rank > s.last_rank
        puts s.user.first_name.to_s+"\t\t\t"+s.net.to_s+"\t\t\t"+s.current_rank.to_s+"\t\t\t"+'V'
      elsif s.current_rank < s.last_rank
        puts s.user.first_name.to_s+"\t\t\t"+s.net.to_s+"\t\t\t"+s.current_rank.to_s+"\t\t\t"+'^'
      else
        puts s.user.first_name.to_s+"\t\t\t"+s.net.to_s+"\t\t\t"+s.current_rank.to_s+"\t\t\t"+'>'
      end
    end
    puts '================================'
     puts"\n"  
    #return share_total.save!
=end
  end
  
  
end
