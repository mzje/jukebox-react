class AddCurrentRatingToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :current_rating, :integer
  end

  def self.down
    remove_column :tracks, :current_rating
  end
end
