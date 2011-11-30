class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.references :book
      t.references :user
      t.string :mood
      t.string :location
      t.string :thoughts

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
