module Model
  class Post < Base
    schema do
      primary_key :url, :string, :auto_increment => false, :size => 255
      text        :content
    end
  end
end
