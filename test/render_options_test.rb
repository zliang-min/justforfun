require 'test_helper'
load 'reset.rb'

context "A render-ish object." do
  setup {
    Person.template_path = TEST_DIR + 'examples'
    Person.new
  }

  context 'Rendered with format.' do
    should('respect format.') {
      topic.render :html
    }.equals(
      Tilt.new(TEST_DIR.join('examples/person.html.erb').to_s).render Person.new
    )
  end
end
