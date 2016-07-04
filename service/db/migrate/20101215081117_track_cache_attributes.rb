class TrackCacheAttributes < ActiveRecord::Migration
  def self.up
    add_column :tracks, :rating_class, :string
    add_column :tracks, :positive_ratings, :string
    add_column :tracks, :negative_ratings, :string
    add_index :tracks, :rating_class
  end

  def self.down
    remove_index :table_name, :column_name
    remove_index :tracks, :rating_class
    remove_column :tracks, :negative_ratings
    remove_column :tracks, :positive_ratings
    remove_column :tracks, :rating_class
  end
end