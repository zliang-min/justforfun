#!/usr/bin/env ruby
# --*-- encoding: UTF-8 --*--
module Amazing
  def self.included mod
    init_method_name = :initialize
    init = mod.instance_method(init_method_name)
    raise NameError, 'hello'
    if init.owner.is_a?(Class)
      old_verbose, $VERBOSE = $VERBOSE, nil
      mod.module_eval do
        remove_method init_method_name
        include(
          Module.new do
            define_method init_method_name do |*args, &blk|
              init.bind(self).call(*args, &blk)
            end
          end
        )
      end
    end
  rescue NameError
    # no-op
    puts $!
  ensure
    $VERBOSE = old_verbose if defined?(old_verbose)
  end

  module InstanceMethods
    def initialize *args, &blk
      super
      puts "I'm amazing"
    end
  end
end

class AA
  def initialize a, b
    puts a, b
  end
end

AA.new 'a', 'b'

AA.class_eval { include Amazing }

AA.new 'o', 'p'
