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

  it "should GET a page with a variable in the path" do
    $db['pages'].insert('path' => '/team/:team', 'title' => 'Team', 'body' => "Team Member {{item.name}} {{item.bio}}")

    $db['team'].insert('name' => 'Paul Clark', 'path' => 'paul-clark', 'bio' => "was president of SFC")    
    $db['team'].insert('name' => 'Kevin Marsh', 'path' => 'kevin-marsh', 'bio' => "started SongMeanings")    

    get '/team/kevin-marsh'
    last_response.should be_ok
    last_response.body.should == "Team Member Kevin Marsh started SongMeanings"

    get '/team/paul-clark'
    last_response.should be_ok
    last_response.body.should == "Team Member Paul Clark was president of SFC"    
  end

  describe "missing pages" do
    it "should return a 404 for a page that doesn't exist" do
      get '/no-page-by-this-name'
      last_response.status.should == 404
    end

    it "should return a custom 404 page if one exists" do
      $db['pages'].insert('path' => '/404', 'title' => 'Team', 'body' => "Y U NO EXIST?!")

      get '/no-page-by-this-name'
      last_response.status.should == 404
      last_response.body.should == "Y U NO EXIST?!"
    end
  end

end