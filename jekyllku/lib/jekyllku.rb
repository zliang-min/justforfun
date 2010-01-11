module Jekyllku
  class << self
    def lib_path
      @lib_path ||= File.expand_path File.dirname(__FILE__)
    end

    def add_lib_path_to_load_path
      $:.unshift lib_path unless [File.dirname(__FILE__), lib_path].any? { |path| $:.include? path }
    end
  end

  add_lib_path_to_load_path

  autoload :Model,     'jekyllky/model'
  autoload :JekyllExt, 'jekyllku/jekyll_ext'
  autoload :WebApp,    'jekyllky/web_app'
end
