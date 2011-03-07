class CreateArticleImages < ActiveRecord::Migration
  def self.up
    create_table :article_images do |t|
      t.string :url, :limit => 255, :null => false
      t.belongs_to :articles

      t.timestamps
    end
  end

  def self.down
    drop_table :article_images
  end
end
