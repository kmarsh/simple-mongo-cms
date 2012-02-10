require File.dirname(__FILE__) + '/spec_helper'

describe 'Main' do
  
  include Rack::Test::Methods
  
  before do
    $mongo = Mongo::Connection.new
    $db = $mongo['ffx-cms']

    $db['snippets'].remove
    $db['snippets'].insert('name' => 'header', 'body' => "header")

    $db['pages'].remove
    $db['pages'].insert('path' => '/', 'title' => 'Home', 'body' => "Homepage")
    $db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => "Team")
  end

  it "should GET a page at /" do
    get '/'
    last_response.should be_ok
    last_response.body.should == "Homepage"
  end

  it "should GET a page at a specific path" do
    get '/team'
    last_response.should be_ok
  end

  describe "missing pages" do
    it "should be 404 for a page that doesn't exist" do
      get '/no-page-by-this-name'
      last_response.status.should == 404
    end
  end
  
end