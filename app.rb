class Website < Sinatra::Base
  use Middleware::One
  use Middleware::Two
  use Middleware::Three

  map '/products' do
    map ':id' do
      get do
        show Product.find(:id)
      end

    end
  end

  has_many :accounts do
    respond_to :html, :xml, :json

    has_one :blog do
      has_many :posts, Posts do
        get '/index', :welcome
      end
    end
  end
end
