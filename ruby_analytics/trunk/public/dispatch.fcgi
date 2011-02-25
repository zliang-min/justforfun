#!/usr/bin/env ruby
# -- encoding: utf8 --

require File.join(File.dirname(__FILE__), 'init')
require 'rack'

Rack::Handler.get('fastcgi').run Rack::Builder.parse_file(File.join(File.dirname(__FILE__), '../config.ru')).first
