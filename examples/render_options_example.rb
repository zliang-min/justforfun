require 'example_helper'

describe "render" do
  before {
    load 'reset.rb'
    Renderish.template_path = FIXTURES_DIR
    @it = Person.new
  }

  it "should respect :type option." do
    @it.render(:type => :html).should eql(
      Tilt.new(File.join(File.dirname(__FILE__), 'person.erb')).render(@it)
    )
  end
end
