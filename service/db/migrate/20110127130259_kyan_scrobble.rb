class KyanScrobble < ActiveRecord::Migration
  def self.up
    add_column :command_histories, :kyan_scrobbled, :boolean, :default => false
    add_index :command_histories, :kyan_scrobbled
  end

  def self.down
    remove_index :command_histories, :kyan_scrobbled
    remove_column :command_histories, :kyan_scrobbled
  end
end