require File.dirname(__FILE__) + '/spec_helper'

describe 'Templates' do
  
  include Rack::Test::Methods

  it "should render snippets" do
    $db['snippets'].update({'name' => 'header'}, {'name' => 'header', 'body' => "<h1>Site Title</h1>"})
    $db['pages'].update({'path' => '/'}, {'path' => '/', 'title' => 'Home', 'body' => "Before{% include 'header' %}After"})

    get '/'
    last_response.should be_ok
    last_response.body.should == "Before<h1>Site Title</h1>After"
  end

  it "should get data from the database" do
    $db['items'].remove
    $db['items'].insert({'sku' => 'ITEM-001'})
    $db['items'].insert({'sku' => 'ITEM-002'})    

    $db['pages'].update({'path' => '/'}, {'path' => '/', 'title' => 'Items', 'body' => "<ul>{% for item in db.items %}<li>{{ item.sku }}</li>{% endfor %}</ul>"})

    get '/'
    last_response.should be_ok
    last_response.body.should == "<ul><li>ITEM-001</li><li>ITEM-002</li></ul>"
  end

  it "should support liquid conditionals" do
    get '/team'
    last_response.should be_ok
    last_response.body.should == "Team"
  end

end