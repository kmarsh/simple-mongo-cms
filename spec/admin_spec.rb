require File.dirname(__FILE__) + '/spec_helper'

describe 'Admin' do
  
  include Rack::Test::Methods

  describe 'index' do
    before do
      $db['pages'].insert('path' => '/', 'title' => 'Home', 'body' => "Homepage")
      $db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => "Team")

      get '/admin'
    end

    it "should GET a page at /admin" do
      last_response.should be_ok
      last_response.body.should include "Admin"
    end

    it "should list pages" do
      last_response.body.should include '/'
      last_response.body.should include '/team'
    end
  end

  describe 'update' do
    before do
      @page1 = $db['pages'].insert('path' => '/', 'title' => 'Home', 'body' => "Homepage")
      @page2 = $db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => "Team")

      put "/admin/pages/#{@page1.to_s}", {:body => "Changed"}
    end

    it "should PUT a page at /admin/pages/:id" do
      last_response.should be_ok
      $db['pages'].find_one({ :path => '/' })['body'].should == "Changed"
    end

    it "should keep the previous body in versions" do
      $db['pages'].find_one({ :path => '/' })['versions'].should == ['Homepage']
    end

    it "should store more than one previous version" do
      put "/admin/pages/#{@page1.to_s}", { :body => "Changed Again" }
      $db['pages'].find_one({ :path => '/' })['versions'].should == ['Homepage', 'Changed']
    end
  end

  describe 'edit' do
    before do
      page1 = $db['pages'].insert('path' => '/', 'title' => 'Home', 'body' => "Homepage")
      page2 = $db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => "Team")

      get "/admin/pages/#{page1.to_s}/edit"
    end

    it "should GET a page at /admin/pages/:id/edit" do
      last_response.should be_ok
      last_response.body.should include "Editing /"
    end    
  end
end