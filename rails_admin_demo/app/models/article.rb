class Article < ActiveRecord::Base
  attr_accessible :title, :keywords, :description, :body

  validates :title, presence: true, length: {maximum: 255}
  validates_length_of :keywords,    maximum: 20
  validates_length_of :description, maximum: 100
end
