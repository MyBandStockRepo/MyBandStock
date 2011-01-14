task :set_user_levels => :environment do
  #copy over the twitter_created_at fields to tweeted_at
  
  shareTotals = ShareTotal.all
  
  for st in shareTotals
    band = st.band
    levels = band.levels.order(:points)
    
    unless levels.blank?
      user_points = st.gross
      user_level = nil
      for lvl in levels
        if lvl.points < user_points
          user_level = lvl
        end
      end
      st.level = user_level
      st.save
    end
    
  end
end
