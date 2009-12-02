class Posts

  include Renderish::Renderable

  def show id
    http.allow :get
    http.accept 'xml', 'json', 'html'

    respond_to model.find(id)
  end

  def delete id
  end

  def index
    Post.all.each { |post| post.render }
    render :index, :collection => posts, :locals => {:author => author}, :object => self
  end

  class Model < ActiveRecord::Base
    set_table_name 'posts'

    include Renderish::Renderable

    self.template_path = ''
    self.template_file = ''
    self.render_scope  = Object

    def self.index
      @posts = all :order => 'created_at DESC'
      render :index
    end

  end

end
