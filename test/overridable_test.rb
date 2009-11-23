require 'riot'
require_relative '../lib/overridale'

context "methods defined in classes" do
  setup {
    class Thing
      def foo
        'Thing.foo'
      end

      def bar a
        yiled a
      end
    end
  }

  should "not be overrided by mixed-in modules" do
    module ModuleA
      def foo
        'ModuleA.foo'
      end

      def bar
        'ModuleA.bar'
      end
    end

    topic.send :include, ModuleA
    topic.new.foo
  end.equals('Thing.foo')

  context "a class includes module Overridable" do
    setup { Thing.send :include, Overridable; Thing }
  end

  assert { topic.foo }.equals('Thing.foo')

  context "mix a module in a class" do

  end

end
