class IndexCommandHistoriesParameters < ActiveRecord::Migration
  def self.up
    add_index :command_histories, :parameters, :length => 30
  end

  def self.down
    remove_index :command_histories, :parameters, :length => 30
  end
end