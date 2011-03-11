# encoding: utf-8
# @auther 梁智敏

require 'bundler'
Bundler.require

$:.unshift File.expand_path('../lib', __FILE__)

ActiveRecord::Base.establish_connection :adapter => :mongodb

class Person < ActiveRecord::Base
end

puts Person.first
