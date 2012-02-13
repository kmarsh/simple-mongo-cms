require 'rubygems'
require 'yaml'
require 'liquid'
require 'sinatra'
require 'mongo'

require 'rack/gridfs'

enable :logging

$mongo = Mongo::Connection.new
$db = $mongo[ENV['MONGO_DB'] || "smcms"]

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def display_for_record(record)
    record['path'] || record['name'] || record['title'] || record['_id'].to_s
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
    $db[method].find().map {|r| RecordDrop.new(r) }
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

# Update a page
put '/admin/:collection/:id' do
  @page = $db[params[:collection]].find_one({:_id => BSON::ObjectId(params[:id])})

  $db[params[:collection]].update({"_id" => BSON::ObjectId(params[:id])}, {
    "$push" => { "versions" => @page['body'] },
    "$set" =>  { "body" => params[:body] }
  })

  "OK"
end

get '/admin/:collection/:id/edit' do
  @page = $db[params[:collection]].find_one({:_id => BSON::ObjectId(params[:id])})

  erb :'admin/edit'
end

get '/admin' do
  collections = $db.collections.reject {|collection| collection.name.match(/(fs|system)\./) }
  
  @content = {}
  collections.each do |collection|
    @content[collection.name] = collection.find({}, { :sort => ['position', :asc] })
  end

  erb :'admin/index'
end

get '*' do
  route = params[:splat].join('/')

  template = $db['pages'].find(:path => route).first

  halt 404 if template.nil?

  @template = Liquid::Template.parse(template['body'])

  assigns = {
    'db' => CollectionDrop.new
  }

  @template.render(assigns)
end