class Website < Sinatra::Base
  use Middleware::One
  use Middleware::Two
  use Middleware::Three

  has_many :accounts do
    respond_to :html, :xml, :json

    has_one :blog do
      has_many :posts, Posts
    end
  end
end
