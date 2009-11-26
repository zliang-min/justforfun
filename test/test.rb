module Foo

  class << self
    def included mod
      mod.extend ::Foo::ClassMethods
    end

    def foo
      @foo
    end

    def foo= foo
      @foo = foo
    end
  end

  module ClassMethods
    def foo
      @foo ||
        begin
          sc = superclass
          while sc.respond_to?(:foo)
            break sc.foo if sc.foo
          end
        end ||
        Foo.foo
    end

    def foo= foo
      @foo = foo
    end
  end

  def foo
    @foo || self.class.foo
  end

  def foo= foo
    @foo = foo
  end

end

class Bar
  include Foo
end

bar = Bar.new

puts '1)'
Foo.foo = 'Foo.foo'
puts 'bar.foo = ' + bar.foo

puts '2)'
Bar.foo = 'Bar.foo'
puts 'bar.foo = ' + bar.foo

puts '3)'
bar.foo = 'bar.foo'
puts 'bar.foo = ' + bar.foo

class Baz < Bar
end

baz = Baz.new

puts '1)'
puts 'baz.foo = ' + baz.foo

puts '4)'
Baz.foo = 'Baz.foo'
puts 'baz.foo = ' + baz.foo

puts '5)'
baz.foo = 'baz.foo'
puts 'baz.foo = ' + baz.foo

class Baa < Bar
end

baa = Baa.new

puts '1)'
puts 'baa.foo = ' + baa.foo

puts '4)'
Baa.foo = 'Baa.foo'
puts 'baa.foo = ' + baa.foo

puts '5)'
baa.foo = 'baa.foo'
puts 'baa.foo = ' + baa.foo
