class NowPlaying < ActiveRecord::Migration
  def self.up
    add_column :command_histories, :now_playing, :boolean, :default => false
    add_index :command_histories, :now_playing
    add_index :command_histories, :user_id
  end

  def self.down
    remove_index :command_histories, :user_id
    remove_index :command_histories, :now_playing
    remove_column :command_histories, :now_playing
  end
end
