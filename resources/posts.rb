class Posts
  include Rack::HTTPResources::Resource

  map '/'

  default_routes! :define_methods => true, :only => [:index, :new, :create, :show]

  GET '/',         :index
  GET '/:id',      :show
  GET '/new',      :new
  PUT '/',         :create
  GET '/:id/edit', :edit
  POST '/:id',     :update
  DELETE '/:id',   :delete

  def show id
    http.allow :get
    http.accept 'xml', 'json', 'html'

    respond_to model.find(id)
  end

  def delete id
  end

  def index
=begin
    http.request
    http.response
    http.allow :get, :head do |method|
      method.get do {
      }

      method.head do {
      }
    end
    http.reject :post
    http.headers
    http.body
    http.session
    http.cookies
=end
    "<html>" \
      "<head>" \
        "<title>Welcome</title>" \
      "</head>" \
      "<body>" \
        "<div>Hello World</div>" \
        "<div>Welcome to here</div>" \
      "</body>" \
    "</html>"
  end

end
