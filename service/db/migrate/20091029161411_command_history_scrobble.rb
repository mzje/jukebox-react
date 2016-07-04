class CommandHistoryScrobble < ActiveRecord::Migration
  def self.up
    add_column :command_histories, :scrobbled, :boolean, :default => false
    add_index :command_histories, :scrobbled
  end

  def self.down
    remove_index :command_histories, :scrobbled
    remove_column :command_histories, :scrobbled
  end
end
