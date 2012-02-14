require 'rubygems'
require 'yaml'
require 'liquid'
require 'sinatra'
require 'mongo'
require 'rack/gridfs'
require './drops/lorem_drop.rb'

enable :logging

$mongo = Mongo::Connection.new
$db = $mongo[ENV['MONGO_DB'] || "smcms"]

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def display_for_record(record)
    return record['name'] if record['name'].to_s.strip != ""
    record['title'] if record['title'].to_s.strip != ""
    record['_id'].to_s 
  end
end

class RecordDrop < Liquid::Drop
  def initialize(record)
    @record = record
  end

  def before_method(method)
    @record[method]
  end
end

class CollectionDrop < Liquid::Drop
  def before_method(method)
    $db[method].find({}, { :sort => ['position', :asc] }).map {|r| RecordDrop.new(r) }
  end
end

module Liquid
  class MongoFileSystem < Liquid::BlankFileSystem
    def read_template_file(template_path, context)
      snippet = $db['snippets'].find(:name => template_path).first
      return nil if snippet.nil?

      snippet['body']
    end
  end
end

use Rack::GridFS, :database => 'smcms'

Liquid::Template.file_system = Liquid::MongoFileSystem.new

# Create a new page
post '/admin/:collection' do

  new_document = params.dup
  new_document.delete("captures")
  new_document.delete("collection")
  new_document.delete("id")
  new_document.delete("splat")

  @page = $db[params[:collection]].insert(new_document)

  "#{@page}"
end

# Display a new form
get '/admin/:collection/new' do
  erb :'admin/new'
end

# Delete a page
delete '/admin/:collection/:id' do
  $db[params[:collection]].remove({:_id => BSON::ObjectId(params[:id])})

  "OK"
end

# Update a page
put '/admin/:collection/:id' do
  @page = $db[params[:collection]].find_one({:_id => BSON::ObjectId(params[:id])})

  new_document = params.dup
  new_document.delete("captures")
  new_document.delete("collection")
  new_document.delete("id")
  new_document.delete("splat")

  $db[params[:collection]].update({"_id" => BSON::ObjectId(params[:id])}, {
    "$push" => { "versions" => @page['body'] },
    "$set" =>  new_document
  })

  "OK"
end

# Update the order of a collection
post '/admin/:collection/order' do
  # TODO: Optimize this with one query, if possible
  params[params[:collection]].each_with_index do |record_id, i|
    $db[params[:collection]].update({"_id" => BSON::ObjectId(record_id)}, {
      "$set" => { "position" => i * 10 }
    })
  end

  "OK"
end

# Display an edit form
get '/admin/:collection/:id/edit' do
  @page = $db[params[:collection]].find_one({:_id => BSON::ObjectId(params[:id])})

  erb :'admin/edit'
end

# Admin "dashboard", lists all content for editing
get '/admin' do
  collections = $db.collections.reject {|collection| collection.name.match(/(fs|system)\./) }
  
  @content = {}
  collections.each do |collection|
    @content[collection.name] = collection.find({}, { :sort => ['position', :asc] })
  end

  erb :'admin/index'
end

def render_template(template, extra_assigns = {})
  parsed_template = Liquid::Template.parse(template['body'])

  assigns = {
    'db' => CollectionDrop.new,
    'lorem' => LoremDrop.new
  }.merge(extra_assigns)

  content_type 'text/css' if template['path'].include?('.css')
  content_type 'application/js' if template['path'].include?('.js')

  parsed_template.render(assigns)
end

get '*' do
  route = params[:splat].join('/')

  # for routing named variables like /team/:team
  # TODO Optimize this...
  path_regexes = $db['pages'].find({}, :fields => "path", :sort => ['position', :asc]).map do |page|
    [Regexp.new(page['path'].gsub(/(:\w+)/, '([A-z\-]+)') + "$"), page['_id']]
  end

  template = nil
  path_regexes.each do |regexp, page_id|
    if (match = route.match(regexp))
      template = $db['pages'].find_one('_id' => page_id)

      route_matches = route.match(regexp)

      record = $db['team'].find_one('path' => route_matches[1])

      return render_template(template, {'item' => RecordDrop.new(record)})
    else
      template = nil
    end
  end

  if template.nil?
    custom_not_found_template = $db['pages'].find(:path => "/404").first
    if custom_not_found_template
      halt 404, render_template(custom_not_found_template)
    else
      halt 404
    end
  end

  render_template(template)
end