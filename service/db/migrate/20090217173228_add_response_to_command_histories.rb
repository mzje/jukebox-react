class AddResponseToCommandHistories < ActiveRecord::Migration
  def self.up
    add_column :command_histories, :response, :text
  end

  def self.down
    remove_column :command_histories, :response
  end
end
