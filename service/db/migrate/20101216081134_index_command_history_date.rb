class IndexCommandHistoryDate < ActiveRecord::Migration
  def self.up
    add_index :command_histories, :created_at
  end

  def self.down
    remove_index :command_histories, :created_at
  end
end