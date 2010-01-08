module Jekyllku::JekyllExt
  autoload :Page, 'jekyllku/jekyll_ext/page'
  autoload :Post, 'jekyllku/jekyll_ext/post'
  autoload :Site, 'jekyllku/jekyll_ext/site'

  def self.active
    require 'jekyll' unless defined?(Jekyll)
    Jekyll::Page.send :include, Page
    Jekyll::Post.send :include, Post
    Jekyll::Site.send :include, Site
  end
end
