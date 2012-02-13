require File.dirname(__FILE__) + '/spec_helper'

describe 'HTTP' do
  
  include Rack::Test::Methods

  before do
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
    last_response.body.should == "Team"
  end

  describe "missing pages" do
    it "should return a 404 for a page that doesn't exist" do
      get '/no-page-by-this-name'
      last_response.status.should == 404
    end

    it "should return a custom 404 page if one exists" do
      $db['pages'].insert('path' => '404', 'title' => 'Team', 'body' => "Y U NO EXIST?!")

      get '/no-page-by-this-name'
      last_response.status.should == 404
      last_response.body.should == "Y U NO EXIST?!"
    end
  end

end