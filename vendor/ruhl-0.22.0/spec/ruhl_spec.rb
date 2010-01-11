# --*-- encoding: UTF-8 --*--

require File.join(File.dirname(__FILE__), 'spec_helper')

describe Ruhl do
  before do
    @co = ContextObject.new
  end

  describe "basic.html" do
    before do
      @html = File.read html(:basic) 
    end

    it "content of p should be content from data_from_method" do
       doc = create_doc
       doc.xpath('//h1').first.content.should == @co.generate_h1
    end
  end

  describe "seo.html" do
    before do
      @html = File.read html(:seo)
    end

    it "meta keywords should be replaced" do
      doc = create_doc
      doc.xpath('//meta[@name="keywords"]').first['content'].
        should == @co.generate_keywords 
    end

    it "meta title should be replaced" do
      doc = create_doc
      doc.xpath('//meta[@name="description"]').first['content'].
        should == @co.generate_description
    end
  end

  describe "medium.html" do
    before do
      @html = File.read html(:medium)
      @doc = create_doc
    end

    it "first data row should equal first user " do
      table = @doc.xpath('/html/body/table/tr//td')
      table.children[0].to_s.should == "Jane"
      table.children[1].to_s.should == "Doe"
      table.children[2].to_s.should == "jane@stonean.com"
    end

    it "last data row should equal last user " do
      table = @doc.xpath('/html/body/table/tr//td')
      table.children[9].to_s.should == "Paul"
      table.children[10].to_s.should == "Tin"
      table.children[11].to_s.should == "paul@stonean.com"
    end
  end

  describe "fragment.html" do
    before do
      @html = File.read html(:fragment)
    end

    it "will be injected into layout.html" do
      doc  = create_doc( html(:layout) )
      doc.xpath('//h1').should_not be_empty
      doc.xpath('//p').should_not be_empty
    end
  end

  shared_examples_for "having sidebar" do
    it "should replace sidebar with partial contents" do
      @doc.xpath('/html/body/div/div/div//h3')[0].inner_html.
        should == "Real Sidebarlinks"

      @doc.xpath('/html/body/div/div/div/ul/li//a')[0].inner_html.
        should == "Real Link 1"
    end
  end

  describe "main_with_sidebar.html" do
    before do
      @html = File.read html(:main_with_sidebar)
      @doc = create_doc
    end

    it_should_behave_like "having sidebar"      
  end

  describe "parameters.html" do
    before do
      @html = File.read html(:parameters)
      @doc = create_doc
    end

    it_should_behave_like "having sidebar"      

    it "should update the h1" do
      @doc.xpath("//div[@id='main']").first.children[1].
        inner_html.should == "Welcome to the Home page"
    end
  end

  shared_examples_for "if with no users" do
    it "table should not render" do
      nodes = @doc.xpath('/html/body//*')
      nodes.children.length.should == 2
      nodes.children[0].to_s.should == "This is the header template"
    end

    it "no user message should render" do
      nodes = @doc.xpath('/html/body//*')
      nodes.children[1].to_s.should == @co.no_users_message
    end
  end

  shared_examples_for "if with users" do
    it "table should render" do
      nodes = @doc.xpath('/html/body//*')
      nodes.children.length.should > 1

      table = @doc.xpath('/html/body/table/tr//td')
      table.children[12].to_s.should == "NoMail"
      table.children[13].to_s.should == "Man"
    end
  end

  describe "if.html" do
    describe "users? is false" do
      before do
        class ContextObject
          def users?
            false
          end
        end

        @html = File.read html(:if)
        @doc = create_doc
      end

      it_should_behave_like "if with no users"      
    end

    describe "users? is true" do
      before do
        class ContextObject
          def users?
            true
          end
        end

        @html = File.read html(:if)
        @doc = create_doc
      end

      it_should_behave_like "if with users"      
    end

    describe "hash returned" do
      before do
        class ContextObject
          def users?
            true
          end
        end

        @html = File.read html(:if_with_hash)
        @doc = create_doc
      end

      it "should use hash appropriately" do
        ptag = @doc.xpath("/html/body/p").first
        ptag["class"].should == "pretty"
        ptag["id"].should == "8675309"
        ptag.inner_html.should=="jenny"
      end
    end

  end

  describe "if_on_collection.html" do
    describe "user_list is empty" do
      before do
        class ContextObject
          def user_list
            []
          end
        end

        @html = File.read html(:if_on_collection)
        @doc = create_doc
      end

      it_should_behave_like "if with no users"      
    end

    describe "user_list is not empty" do
      before do
        class ContextObject
          def user_list
            [ 
              TestUser.new('Jane', 'Doe', 'jane@stonean.com'),
              TestUser.new('John', 'Joe', 'john@stonean.com'),
              TestUser.new('Jake', 'Smo', 'jake@stonean.com'),
              TestUser.new('Paul', 'Tin', 'paul@stonean.com'),
              TestUser.new('NoMail', 'Man')
            ]
          end
        end

        @html = File.read html(:if_on_collection)
        @doc = create_doc
      end

      it_should_behave_like "if with users"      
    end
  end

  describe "loop.html" do
    before do
      @html = File.read html(:loop)
    end

    it "will be injected into layout.html" do
      doc  = create_doc
      options = doc.xpath('/html/body/select//option')
      options.children.length.should == @co.states_for_select.length
    end
  end

  describe "form.html" do
    before do
      @html = File.read html(:main_with_form)
      @doc  = create_doc
    end

    it "first name will be set" do
      @doc.xpath('/html/body/div//input')[0]['value'].should == "Jane"
    end

    it "last name will be set" do
      @doc.xpath('/html/body/div//input')[1]['value'].should == "Doe"
    end

    it "email will be set" do
      @doc.xpath('/html/body/div//input')[2]['value'].should == "jane@stonean.com"
    end
  end

  describe "hash.html" do
    before do
      @html = File.read html(:hash)
    end

    it "have radio inputs with proper attributes" do
      doc  = create_doc
      nodes = doc.xpath('/html/body/label//input')
      nodes[0]['value'].should == 'doe'
      nodes[1]['value'].should == 'joe'
      nodes[2]['value'].should == 'smo'
      nodes[3]['value'].should == 'tin'
      nodes[4]['value'].should == 'man'
    end
  end

  shared_examples_for "if with user" do
    it "first name will be set" do
      @doc.xpath('/html/body/div//input')[0]['value'].should == "Jane"
    end

    it "last name will be set" do
      @doc.xpath('/html/body/div//input')[1]['value'].should == "Doe"
    end

    it "email will be set" do
      @doc.xpath('/html/body/div//input')[2]['value'].should == "jane@stonean.com"
    end
  end

  describe "use.html" do
    before do
      @html = File.read html(:use)
      @doc  = create_doc
    end

    it_should_behave_like "if with user"      
  end

  describe "use_if.html" do
    before do
      @html = File.read html(:use_if)
      @doc  = create_doc
    end

    it_should_behave_like "if with user"      
  end
  
  describe "collection_of_strings.html" do
    before do
      @html = File.read html(:collection_of_strings)
      @doc  = create_doc
    end

    describe "with no nested data-ruhls or other actions" do
      it "will have 5 line items" do
        @doc.xpath("//ul[@id='call-to_s']").first.children.length.should == 10
      end

      it "will have correct content" do
        @doc.xpath("//ul[@id='call-to_s']//li").first.inner_html.should == "Object oriented"
      end

      describe 'called from within a _use' do
        it "will have correct line items" do
          @doc.xpath("/html/body//ul[@id='_use-call-to_s']/li").children.length.should == 2
        end
      
        it "will have correct content" do
          @doc.xpath("/html/body/ul[@id='_use-call-to_s']//li").first.inner_html.should == "Auntie"
        end
      end
    end

    describe "with a nested data-ruhl" do
      it "will have 5 line items" do
        @doc.xpath("/html/body//ul[@id='call-upcase']").first.children.length.should == 10
      end
    
      it "will have correct content" do
        @doc.xpath("/html/body/ul[@id='call-upcase']/li//span").first.inner_html.
          should == "OBJECT ORIENTED"
      end
    end
    
    describe "with an additional action" do
      it "will have 5 line items" do
        @doc.xpath("/html/body//ul[@id='call-reverse']").first.children.length.should == 10
      end
    
      it "will have correct content" do
        @doc.xpath("/html/body/ul[@id='call-reverse']//li").first.inner_html.
          should == "detneiro tcejbO"
      end
    
      it "last item will have correct content" do
        @doc.xpath("/html/body/ul[@id='call-reverse']//li").last.inner_html.
          should == "ecruos nepo"
      end
    end
  end
      

  
  describe "collection_of_hashes.html" do
    describe "user_list is not empty" do
      before do
        @html = File.read html(:collection_of_hashes)
        @doc = create_doc
      end


      it "should have option for each state" do
        options = @doc.xpath('/html/body/select//option')
        options.children.length.should == @co.state_options.length
      end
    end
  end

  describe "special.html" do
    before do
      @html = File.read html(:special)
      @doc  = create_doc
    end

    it "will convert entities" do
      ps = @doc.xpath("/html/body/p")
      ps[0].inner_html.should == "Here is a space and another one."
      ps[1].inner_html.should == "RuHL © 2009"

      # To verify everything is correct, I did it the old fashioned way
      # File.open('test.html',"w") do |f|
      #   f << @doc.to_s
      # end
    end
  end

  describe "swap.html" do
    before do
      @html = File.read html(:swap)
      @doc  = create_doc
    end

    it "will convert entities" do
      ps = @doc.xpath("/html/body/p")
      ps.inner_html.should == "The programming language, Ruby, is awesome."
    end
  end

  describe "when no method" do
    before do
      @html = "<p data-ruhl='nonexistant_method'>I am bad</p>"
    end

    it 'should complain' do
      lambda{ @doc  = create_doc }.should raise_error(NoMethodError)
    end
  end

  describe "when no partial" do
    before do
      @html = "<p data-ruhl='_partial: partial|no file'>I am bad</p>"#File.read html(:debug)
    end

    it 'should complain' do
      lambda{ @doc  = create_doc }.should raise_error(Ruhl::PartialNotFoundError)
    end
  end

end



