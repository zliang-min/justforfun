#!/usr/bin/env ruby
# encoding: utf-8

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ruhl'

class SimpleTest
  def title
    'Gimi Says'
  end

  def name
    'Gimi Liang'
  end

  def to_html
    Ruhl::Engine.new(DATA.read).render self
  end
end

if __FILE__ == $0
  puts SimpleTest.new.to_html
end

__END__
<html>
  <head>
    <title data-ruhl="title">untitled</title>
  </head>
  <body>
    <p>My name is <span data-ruhl="_swap:name">name</span>. Thank you for using RuHL!</p>
  </body>
</html>
