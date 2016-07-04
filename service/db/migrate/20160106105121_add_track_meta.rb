class AddTrackMeta < ActiveRecord::Migration
  def change
   add_column :tracks, :artist_name, :string
   add_index :tracks, :artist_name

   add_column :tracks, :track_title, :string
   add_index :tracks, :track_title

   add_column :tracks, :release_name, :string
   add_index :tracks, :release_name
  end
end
