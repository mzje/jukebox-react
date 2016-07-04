class ScrobblerUpdates < ActiveRecord::Migration
  def self.up
    add_column :users, :lastfm_name, :string
    add_column :users, :lastfm_session_key, :string
  end

  def self.down
    remove_column :users, :lastfm_session_key
    remove_column :users, :lastfm_name
  end
end
