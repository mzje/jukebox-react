class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :track_id
      t.integer :user_id
      t.boolean :aye
      t.text :filename

      t.timestamps
    end
    add_index :votes, [:track_id, :aye]
    add_index :votes, [:filename, :user_id]
  end

  def self.down
    drop_table :votes
  end
end
