class UpdateFilenameIndex < ActiveRecord::Migration
  def self.up
    add_index :tracks, :filename, :length => 30
  end

  def self.down
    remove_index :tracks, :filename, :length => 30
  end
end