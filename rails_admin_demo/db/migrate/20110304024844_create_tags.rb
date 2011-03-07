class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :title, :limit => 30, :null => false, :unique => true
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
