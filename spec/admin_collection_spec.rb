require File.dirname(__FILE__) + '/spec_helper'

describe 'Admin with other collections' do
  
  include Rack::Test::Methods

  before do
    @project1 = $db['projects'].insert('title' => 'Big One', 'client' => 'Pepsi', 'narrative' => "We did something great...", :position => 10)
    @project2 = $db['projects'].insert('title' => 'Little One', 'client' => 'Coke', 'narrative' => "We did something great...", :position => 20)
  end

  describe 'index' do
    before do
      get '/admin'
    end

    it "should list projects at /admin" do
      last_response.should be_ok
      last_response.body.should include "Big One"
    end
  end

  describe 'order' do
    before do
      post "/admin/projects/order", {"projects[]" => [@project2.to_s, @project1.to_s]}
    end

    it "should update the position of records" do
      last_response.should be_ok
      p1 = $db['projects'].find_one({ :_id => @project1 })
      p2 = $db['projects'].find_one({ :_id => @project2 })

      p2['position'].should be < p1['position']
    end
  end

  describe 'update' do
    before do

      put "/admin/projects/#{@project1}", {:body => "Changed"}
    end

    it "should PUT a page at /admin/projects/:id" do
      last_response.should be_ok
      $db['projects'].find_one({ :_id => @project1 })['body'].should == "Changed"
    end
  end

  describe 'edit' do
    before do
      get "/admin/projects/#{@project1}/edit"
    end

    it "should GET a page at /admin/projects/:id/edit" do
      last_response.should be_ok
      last_response.body.should include "Editing Big One"
    end    
  end
end