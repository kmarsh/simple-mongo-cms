require File.dirname(__FILE__) + '/spec_helper'

describe 'Templates' do
  
  include Rack::Test::Methods

  before do
    $db['snippets'].insert('name' => 'header', 'body' => "<h1>Site Title</h1>")

    $db['pages'].insert('path' => '/snippet', 'title' => 'Home', 'body' => "Before{% include 'header' %}After")
    $db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => "Team")
  end

  it "should render snippets" do
    get '/snippet'
    last_response.should be_ok
    last_response.body.should == "Before<h1>Site Title</h1>After"
  end

  it "should get data from the database" do
    $db['items'].insert('sku' => 'ITEM-001')
    $db['items'].insert('sku' => 'ITEM-002')    

    $db['pages'].insert('path' => '/items', 'title' => 'Items', 'body' => "<ul>{% for item in db.items %}<li>{{ item.sku }}</li>{% endfor %}</ul>")

    get '/items'
    last_response.should be_ok
    last_response.body.should == "<ul><li>ITEM-001</li><li>ITEM-002</li></ul>"
  end

  it "should support liquid conditionals" do
    get '/team'
    last_response.should be_ok
    last_response.body.should == "Team"
  end

end