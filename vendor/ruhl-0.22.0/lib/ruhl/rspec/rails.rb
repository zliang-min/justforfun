require 'nokogiri'

module Ruhl
  module Rspec
    module Rails
      def self.included(parent)

        ruby = <<-RUBY
          before do
            f = "#{caller[0].split(':').first}"
            f = f.sub("\.\/spec","#{::Rails.root}\/app").sub('_spec.rb','')
            @view_nodes = Nokogiri::HTML.fragment(File.read(f))
          end

          def ruhl_view
            @view_nodes
          end

          def data_ruhl(path) 
            tag  = ruhl_view.css(path).first
            unless tag
              raise Spec::Matchers::MatcherError.new("CSS selector: "+ path + " not found")
            end
            tag.attribute('data-ruhl').to_s
          end
        RUBY

        parent.class_eval ruby
      end
    end
  end
end
