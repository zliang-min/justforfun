class Posts
  include Rack::HTTPResources::Resource

  def index
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

  def show id
    # requires :host_name => '', :user_agent => ''
    "what do you want?"
  end

  def comment id, comment_info
  end

end
