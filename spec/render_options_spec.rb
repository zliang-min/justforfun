require 'spec_helper'

describe "render" do
  before :all do
    load 'reset.rb'
    Renderish.configuration { |config| config.template_path = FIXTURES_DIR }
    @it = Person.new
  end

  it "should render the correct template if it's specified." do
    @it.render(:another).should eql(
      File.read(FIXTURES_DIR.join('expectations/person/another.erb'))
    )
    @it.render("person/another").should eql(
      File.read(FIXTURES_DIR.join('expectations/person/another.erb'))
    )
    @it.render(FIXTURES_DIR.expand_path.join('person/another')).should eql(
      File.read(FIXTURES_DIR.join('expectations/person/another.erb'))
    )
  end

  it "should respect :type option." do
    @it.render(:type => :html).should eql(
      Tilt.new(FIXTURES_DIR.join('person.html.erb').to_s).render(@it)
    )

    lambda { @it.render(:type => :awful) }.should \
      raise_error(Renderish::NoTemplateError)
  end

  it "should respect :engine option." do
    @it.render(:engine => :haml).should eql(
      Tilt.new(FIXTURES_DIR.join('person.haml').to_s).render(@it)
    )

    lambda { @it.render(:engine => :sass) }.should \
      raise_error(Renderish::NoTemplateError)

    lambda { @it.render(:engine => :not_supported) }.should \
      raise_error(Renderish::UnsupportedEngine)
  end

  it "should respect :layout option." do
    @it.render(:layout => true).should eql(
      File.read(FIXTURES_DIR.join('expectations/person.erb.with.layout'))
    )
    @it.render(:layout => :person).should eql(
      File.read(FIXTURES_DIR.join('expectations/person.erb.with.layout'))
    )
    @it.render(:layout => "layout/person").should eql(
      File.read(FIXTURES_DIR.join('expectations/person.erb.with.layout'))
    )
    @it.render(:layout => FIXTURES_DIR.expand_path.join('layout/person')).should eql(
      File.read(FIXTURES_DIR.join('expectations/person.erb.with.layout'))
    )
  end
end
