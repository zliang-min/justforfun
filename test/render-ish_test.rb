require 'test_helper'

context "A render-ish object." do
  setup { Person.new }

  should("be able to render").respond_to(:render)

  context "Its render method." do
    context "By default" do
      setup {
        raise RuntimeError, "There is a `person.erb' file in the current directory. Please delete/rename it to continue this test." if File.exists?('./person.erb')
        File.open('./person.erb', 'w') { |f|
          f << "Test view for <%= self.class.name %>. Generated in test file."
        }

        topic
      }

      should('render one of all supported templates in current directory.') {
        res = topic.render
        require 'fileutils'
        FileUtils.rm './person.erb'
        res
      }.equals(
        "Test view for Person. Generated in test file."
      )
    end

    context "Set template path" do
      context "in Renderish." do
        setup {
          Renderish.template_path = TEST_DIR + 'examples'
          topic
        }

        should('render template in the right location.') {
          topic.render
        }.equals(
          Tilt.new(TEST_DIR.join('examples/person.erb').to_s).render Person.new
        )
      end

      context "in class." do
        setup {
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

      context "in instance." do
        setup {
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

    context "Set template file" do
      setup { Person.template_path = TEST_DIR + 'examples'; topic }

      context "in Renderish." do
        setup {
          Renderish.template_file = 'person_alt'
          topic
        }

        should('render the right template.') {
          topic.render
        }.equals(
          Tilt.new(TEST_DIR.join('examples/person_alt.erb').to_s).render Person.new
        )
      end

      context "in class." do
        setup {
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

      context "in instance." do
        setup {
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

    context "Reset template_path and template_file." do
      setup {
        Person.template_path = TEST_DIR + 'examples'
        Person.template_file = nil

        topic
      }

      context 'Rendered with format.' do
        should('respect format.') {
          topic.render :type => :html
        }.equals(
          Tilt.new(TEST_DIR.join('examples/person.html.erb').to_s).render Person.new
        )
      end

=begin
      context "" do
        should() do
          topic.render :html => :show
          topic.render :show,
            :type => :html,
            :format => :erb,
            :layout => :abc
        end
      end
=end
    end
  end
end
