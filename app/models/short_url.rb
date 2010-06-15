class ShortUrl < ActiveRecord::Base
  belongs_to :maker, :polymorphic => { :default => 'User' }
end
