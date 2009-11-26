require 'pathname'
__DIR__ = Pathname(__FILE__).dirname

require 'riot'
require_relative '../lib/render-ish'

Dir['examples/*.rb'].each { |rb| require rb }

context "An instance of a class which includes Renderish." do
  setup { Person.new }

  should("be able to render").respond_to(:render)

  context "The render method." do
    should('render the template named with #{class.name}.#{registered_exts} by default.') {
      topic.render
    }.equals(
      Tilt.new('./person.erb').render Person.new
    )

    should('render the coresponding template when format is specified.') {
      topic.render :html
    }.equals(
      Tilt.new('./person.html.erb').render Person.new
    )

    context "Specify template path in class." do
      setup {
      }
    end
  end
end
