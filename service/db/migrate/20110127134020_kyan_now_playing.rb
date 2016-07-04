class KyanNowPlaying < ActiveRecord::Migration
  def self.up
    add_column :command_histories, :kyan_now_playing, :boolean, :default => false
    add_index :command_histories, :kyan_now_playing
  end

  def self.down
    remove_index :command_histories, :kyan_now_playing
    remove_column :command_histories, :kyan_now_playing
  end
end