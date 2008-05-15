class ActsAsMessagesMigration < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :sender_id, :null => false
      t.integer :receiver_id,  :null => false
      t.integer :parent_id, :default => 0
      t.string  :title, :null => false
      t.text  :body
      t.integer :read,  :default => 0
      t.integer :sender_deleted, :default => 0
      t.integer :receiver_deleted,  :default => 0
      t.timestamps
    end
    
  end
  
  def self.down
    drop_table :messages
  end
end
