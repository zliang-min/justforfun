class CreateArticleImages < ActiveRecord::Migration
  def self.up
    create_table :article_images do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :article_images
  end
end
