require File.dirname(__FILE__) + '/spec_helper'

describe 'HTTP' do
  
  include Rack::Test::Methods

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
  end

end