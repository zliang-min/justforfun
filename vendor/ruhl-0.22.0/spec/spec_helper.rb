require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ruhl]))

def html(name)
  File.join( File.dirname(__FILE__), 'html', "#{name}.html" )
end

def create_doc(layout = nil)
  options = {:layout => layout} 

  html = Ruhl::Engine.new(@html, :layout => layout).
    render(ContextObject.new)

  do_parse(html)
end

def do_parse(html)
  Nokogiri::HTML(html)
end


class TestUser
  attr_accessor :id, :first_name, :last_name, :email, :nicknames

  def initialize(first, last , email = nil)
    @first_name = first
    @last_name  = last
    @email = email
    @id = rand(100)
    @nicknames = ['Auntie','Pattern']
  end

  def radio_input
    { :inner_html => first_name, :id => "user_#{id.to_s}", 
      :name => "user[id]", :value => last_name.downcase}
  end
end
 
def user
  TestUser.new('Jane', 'Doe', 'jane@stonean.com')
end


class ContextObject
  def language
    'Ruby'
  end

  def generate_h1
    "data from presenter"     
  end

  def data_from_method
    "I am data from a method"
  end

  def generate_description
    "I am a custom meta description"
  end

  def generate_keywords
    "I, am, custom, keywords"
  end

  def my_content
    "hello from my content."
  end

  def partial(name)
    html(name.to_sym)
  end

  def page_title(page)
    "Welcome to the #{page}"
  end

  def sidebar_partial
    html(:sidebar)
  end

  def form_partial
    html(:form)
  end

  def user_list
    [ 
      TestUser.new('Jane', 'Doe', 'jane@stonean.com'),
      TestUser.new('John', 'Joe', 'john@stonean.com'),
      TestUser.new('Jake', 'Smo', 'jake@stonean.com'),
      TestUser.new('Paul', 'Tin', 'paul@stonean.com'),
      TestUser.new('NoMail', 'Man')
    ]
  end

  def users?
    true
  end

  def no_users_message
    "Sorry no users found"
  end

  def states_for_select
    state = Struct.new(:abbr, :name)
    [ state.new('AL', 'Alabama'),
      state.new('AK', 'Alaska'),
      state.new('AZ', 'Arizona'),
      state.new('AR', 'Arkansas'),
      state.new('CA', 'California'),
      state.new('CO', 'Colorado'),
      state.new('CT', 'Connecticut'),
      state.new('DE', 'Delaware'),
      state.new('FL', 'Florida'),
      state.new('GA', 'Georgia'),
      state.new('HI', 'Hawaii'),
      state.new('ID', 'Idaho'),
      state.new('IL', 'Illinois'),
      state.new('IN', 'Indiana'),
      state.new('IA', 'Iowa'),
      state.new('KS', 'Kansas'),
      state.new('KY', 'Kentucky'),
      state.new('LA', 'Louisiana'),
      state.new('ME', 'Maine'),
      state.new('MD', 'Maryland'),
      state.new('MA', 'Massachusetts'),
      state.new('MI', 'Michigan'),
      state.new('MN', 'Minnesota'),
      state.new('MS', 'Mississippi'),
      state.new('MO', 'Missouri'),
      state.new('MT', 'Montana'),
      state.new('NE', 'Nebraska'),
      state.new('NV', 'Nevada'),
      state.new('NH', 'New Hampshire'),
      state.new('NJ', 'New Jersey'),
      state.new('NM', 'New Mexico'),
      state.new('NY', 'New York'),
      state.new('NC', 'North Carolina'),
      state.new('ND', 'North Dakota'),
      state.new('OH', 'Ohio'),
      state.new('OK', 'Oklahoma'),
      state.new('OR', 'Oregon'),
      state.new('PA', 'Pennsylvania'),
      state.new('RI', 'Rhode Island'),
      state.new('SC', 'South Carolina'),
      state.new('SD', 'South Dakota'),
      state.new('TN', 'Tennessee'),
      state.new('TX', 'Texas'),
      state.new('UT', 'Utah'),
      state.new('VT', 'Vermont'),
      state.new('VA', 'Virginia'),
      state.new('WA', 'Washington'),
      state.new('WV', 'West Virginia'),
      state.new('WI', 'Wisconsin'),
      state.new('WY', 'Wyoming')]
  end

  def state_options
    [ {:value => 'AL', :inner_html => 'Alabama'},
      {:value => 'AK', :inner_html => 'Alaska'},
      {:value => 'AZ', :inner_html => 'Arizona'},
      {:value => 'AR', :inner_html => 'Arkansas'},
      {:value => 'CA', :inner_html => 'California'},
      {:value => 'CO', :inner_html => 'Colorado'},
      {:value => 'CT', :inner_html => 'Connecticut'},
      {:value => 'DE', :inner_html => 'Delaware'},
      {:value => 'FL', :inner_html => 'Florida'},
      {:value => 'GA', :inner_html => 'Georgia'},
      {:value => 'HI', :inner_html => 'Hawaii'},
      {:value => 'ID', :inner_html => 'Idaho'},
      {:value => 'IL', :inner_html => 'Illinois'},
      {:value => 'IN', :inner_html => 'Indiana'},
      {:value => 'IA', :inner_html => 'Iowa'},
      {:value => 'KS', :inner_html => 'Kansas'},
      {:value => 'KY', :inner_html => 'Kentucky'},
      {:value => 'LA', :inner_html => 'Louisiana'},
      {:value => 'ME', :inner_html => 'Maine'},
      {:value => 'MD', :inner_html => 'Maryland'},
      {:value => 'MA', :inner_html => 'Massachusetts'},
      {:value => 'MI', :inner_html => 'Michigan'},
      {:value => 'MN', :inner_html => 'Minnesota'},
      {:value => 'MS', :inner_html => 'Mississippi'},
      {:value => 'MO', :inner_html => 'Missouri'},
      {:value => 'MT', :inner_html => 'Montana'},
      {:value => 'NE', :inner_html => 'Nebraska'},
      {:value => 'NV', :inner_html => 'Nevada'},
      {:value => 'NH', :inner_html => 'New Hampshire'},
      {:value => 'NJ', :inner_html => 'New Jersey'},
      {:value => 'NM', :inner_html => 'New Mexico'},
      {:value => 'NY', :inner_html => 'New York'},
      {:value => 'NC', :inner_html => 'North Carolina'},
      {:value => 'ND', :inner_html => 'North Dakota'},
      {:value => 'OH', :inner_html => 'Ohio'},
      {:value => 'OK', :inner_html => 'Oklahoma'},
      {:value => 'OR', :inner_html => 'Oregon'},
      {:value => 'PA', :inner_html => 'Pennsylvania'},
      {:value => 'RI', :inner_html => 'Rhode Island'},
      {:value => 'SC', :inner_html => 'South Carolina'},
      {:value => 'SD', :inner_html => 'South Dakota'},
      {:value => 'TN', :inner_html => 'Tennessee'},
      {:value => 'TX', :inner_html => 'Texas'},
      {:value => 'UT', :inner_html => 'Utah'},
      {:value => 'VT', :inner_html => 'Vermont'},
      {:value => 'VA', :inner_html => 'Virginia'},
      {:value => 'WA', :inner_html => 'Washington'},
      {:value => 'WV', :inner_html => 'West Virginia'},
      {:value => 'WI', :inner_html => 'Wisconsin'},
      {:value => 'WY', :inner_html => 'Wyoming'}]
  end

  def hash_value
    {:class => "pretty", :id => "8675309", :inner_html => "jenny"}
  end

end

def points_of_interest
  [ "Object oriented", "dynamic", "mixins", "blocks", "open source"]
end
