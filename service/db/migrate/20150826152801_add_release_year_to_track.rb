class AddReleaseYearToTrack < ActiveRecord::Migration
  def change
    add_column :tracks, :release_year, :integer
    add_index :tracks, :release_year
  end
end
