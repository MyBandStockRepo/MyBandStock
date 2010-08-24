class InitializeUserRanks < ActiveRecord::Migration
  def self.up
    ShareTotal.initialize_ranks
  end

  def self.down
  end
end
