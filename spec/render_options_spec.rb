require 'spec_helper'

describe "render" do
  before {
    Renderish.template_path = File.join(File.dirname(__FILE__), 'examples')
    @it = Person.new
  }

  it "should respect :type option." do
    @it.render(:type => :html).must_equal \
      Tilt.new(File.join(File.dirname(__FILE__), 'examples/person.erb')).render(@it)
  end
end
