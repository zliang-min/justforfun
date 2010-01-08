lib_dir = File.dirname __FILE__
$:.unshift File.expand_path(lib_dir) unless [lib_dir, File.expand_path(lib_dir)].any? { |path| $:.include? path }

module Jekyllku
  autoload :JekyllExt, 'jekyllku/jekyll_ext'
  autoload :Model,     'jekyllky/model'
  autoload :RackApp,   'jekyllky/rack_app'
end
