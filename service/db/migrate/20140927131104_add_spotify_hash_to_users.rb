class AddSpotifyHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :spotify_hash, :text
  end
end
