class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title, :null => false
      t.string :keywords, :length => 20
      t.string :description, :length => 100
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
