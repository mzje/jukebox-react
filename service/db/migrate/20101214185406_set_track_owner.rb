class SetTrackOwner < ActiveRecord::Migration
  def self.up
    add_column :tracks, :owner, :string
  end

  def self.down
    remove_index :tracks, :owner
    remove_column :tracks, :owner
  end
end