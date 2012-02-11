require 'rubygems'
require 'yaml'
require 'liquid'
require 'sinatra'
require 'mongo'

$mongo = Mongo::Connection.new
$db = $mongo[ENV['MONGO_DB'] || "smcms"]

def benchmark(name = "Untitled", &block)
  start = Time.now.to_f
  yield
  puts "%s: %0.6f" % [name, Time.now.to_f - start]
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

Liquid::Template.file_system = Liquid::MongoFileSystem.new

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