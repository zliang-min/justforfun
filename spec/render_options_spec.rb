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

  it "should respect :format option." do
    @it.render(:format => :html).should eql(
      Tilt.new(FIXTURES_DIR.join('person.html.erb').to_s).render(@it)
    )

    lambda { @it.render(:format => :awful) }.should \
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

  describe "use :source option." do
    before do
      @source = <<__SOURCE__
body
  font:
    size: 10px
    weight: bold
__SOURCE__
      @result = <<__RESULT__
body {
  font-size: 10px;
  font-weight: bold; }
__RESULT__
    end
    it "should fail if no template engines are specified." do
      lambda { @it.render(:source => @source) }.should \
        raise_error(RuntimeError, "You have specified template source without template engine.")
    end

    it "should work properly." do
      @it.render(:source => @source, :engine => :sass).should eql(@result)
    end
  end
end
