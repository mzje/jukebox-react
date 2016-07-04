class CreateCommandHistories < ActiveRecord::Migration
  def self.up
    create_table :command_histories do |t|
      t.string :command
      t.text :parameters
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :command_histories
  end
end
