class ArtworkUrl < ActiveRecord::Migration
  def self.up
    add_column :tracks, :artwork_url, :string
  end

  def self.down
    remove_column :tracks, :artwork_url
  end
end