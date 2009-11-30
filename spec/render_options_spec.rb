require 'spec_helper'

describe "render" do
  before :all do
    load 'reset.rb'
    Renderish.template_path = FIXTURES_DIR
    @it = Person.new
  end

  it "should respect :type option." do
    @it.render(:type => :html).should eql(
      Tilt.new(File.join(FIXTURES_DIR.join('person.html.erb').to_s)).render(@it)
    )

    lambda { @it.render(:type => :awful) }.should \
      raise_error(Renderish::NoTemplateError)
  end

  it "should respect :engine option." do
    @it.render(:engine => :haml).should eql(
      Tilt.new(File.join(FIXTURES_DIR.join('person.haml').to_s)).render(@it)
    )

    lambda { @it.render(:engine => :sass) }.should \
      raise_error(Renderish::NoTemplateError)

    lambda { @it.render(:engine => :not_supported) }.should \
      raise_error(Renderish::UnsupportedEngine)
  end

  it "should respect :layout option." do
    @it.render(:layout => true)
    @it.render(:layout => :layout_2nd)
    @it.render(:layout => "path/to/layout")
    @it.render(:layout => "/path/to/layout")
  end
end
