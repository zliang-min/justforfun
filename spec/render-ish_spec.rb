require 'spec_helper'

describe "A render-ish object" do
  before { @it = Person.new }

  it "should be able to render" do
    @it.must_respond_to(:render)
  end

  describe "default render behavior" do
    before {
      raise RuntimeError, "There is a `person.erb' file in the current directory." \
        "Please delete/rename it to continue this test." if File.exists?('./person.erb')

      File.open('./person.erb', 'w') { |f|
        f << "Test view for <%= self.class.name %>. Generated in test file."
      }
    }

    after {
      require 'fileutils'
      FileUtils.rm './person.erb'
    }

    it "should render one of all supported templates in current directory." do
      @it.render.must_equal("Test view for Person. Generated in test file.")
    end
  end

  describe "Set template path" do
    describe "in Renderish." do
      before {
        Renderish.template_path = TEST_DIR + 'examples'
      }

      it 'should render template in the right location.' do
        @it.render.must_equal \
          Tilt.new(TEST_DIR.join('examples/person.erb').to_s).render(Person.new)
      end
    end

    describe "in class." do
      before {
        Renderish.template_path = "/path/that/i/donot/care"
        Person.template_path = TEST_DIR + 'examples'
        topic
      }

      should('render template in the right location.') {
        topic.render
      }.equals(
        Tilt.new(TEST_DIR.join('examples/person.erb').to_s).render Person.new
      )
    end

    describe "in instance." do
      before {
        Renderish.template_path = "/path/that/i/donot/care"
        Person.template_path = "/path/that/i/donot/care/too"
        topic.template_path = TEST_DIR + 'examples'
        topic
      }

      should('render template in the right location.') {
        topic.render
      }.equals(
        Tilt.new(TEST_DIR.join('examples/person.erb').to_s).render Person.new
      )
    end
  end

  describe "Set template file" do
    before { Person.template_path = TEST_DIR + 'examples'; topic }

    describe "in Renderish." do
      before {
        Renderish.template_file = 'person_alt'
        topic
      }

      should('render the right template.') {
        topic.render
      }.equals(
        Tilt.new(TEST_DIR.join('examples/person_alt.erb').to_s).render Person.new
      )
    end

    describe "in class." do
      before {
        Renderish.template_file = "not_exist_file"
        Person.template_file = 'person_alt'
        topic
      }

      should('render the right template.') {
        topic.render
      }.equals(
        Tilt.new(TEST_DIR.join('examples/person_alt.erb').to_s).render Person.new
      )
    end

    describe "in instance." do
      before {
        Renderish.template_file = "not_exist_file"
        Person.template_file = "not_exist_file_2"
        topic.template_file = "person_alt"
        topic
      }

      should('render the right template.') {
        topic.render
      }.equals(
        Tilt.new(TEST_DIR.join('examples/person_alt.erb').to_s).render Person.new
      )
    end
  end
end
