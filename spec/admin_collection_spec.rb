require File.dirname(__FILE__) + '/spec_helper'

describe 'Admin with other collections' do
  
  include Rack::Test::Methods

  before do
    @project1 = $db['projects'].insert('title' => 'Big One', 'client' => 'Pepsi', 'narrative' => "We did something great...", :position => 10)
    @project2 = $db['projects'].insert('title' => 'Little One', 'client' => 'Coke', 'narrative' => "We did something great...", :position => 20)
  end

  describe 'delete' do
    before do
      delete "/admin/projects/#{@project1}"
    end

    it "should delete the project" do
      last_response.should be_ok
      $db['projects'].find_one({ :_id => @project1 }).should == nil
    end
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

  describe 'new' do
    before do
      get "/admin/pages/new"
    end

    it "should render a form to add new content" do
      last_response.should be_ok
    end    
  end

  describe 'create' do
    before do
      post "/admin/projects", { :body => "Created" }
    end

    it "should POST a project at /admin/projects" do
      last_response.should be_ok
    end

    it "returns the ID with the saved content body" do
      $db['projects'].find_one({ :_id => BSON::ObjectId(last_response.body.to_s.strip) })['body'].should == "Created"
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

  describe 'update with other fields' do
    before do
      put "/admin/projects/#{@project1}", {:foobar => "Baz"}
    end

    it "should PUT a page at /admin/projects/:id" do
      last_response.should be_ok
      $db['projects'].find_one({ :_id => @project1 })['foobar'].should == "Baz"
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