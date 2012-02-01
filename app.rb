require 'rubygems'
require 'yaml'
require 'liquid'
require 'sinatra'
require 'mongo'

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

header = <<LIQUID
<h1>&lt;form&gt; &amp;&amp; f(x)</h1>
LIQUID

home = <<LIQUID
{% include 'header' %}
<ul>
  {% for page in db.pages %}
  <li><a href="{{ page.path }}">{{ page.title }}</a></li>
  {% endfor %}
</ul>

<p>Welcome! Blah blah</p>
LIQUID

team = <<LIQUID
{% include 'header' %}
<h2>Team</h2>
<ul>
{% for person in db.team %}
  <li>{{ person.name }}</li>
{% endfor %}
</ul>
LIQUID

recent_work = <<LIQUID
{% include 'header' %}
<h2>Recent Work</h2>
<ul>
{% for person in db.team %}
  <li>{{ person.name }}</li>
{% endfor %}
</ul>
LIQUID

$mongo = Mongo::Connection.new
$db = $mongo['ffx-cms']

$db['snippets'].remove
$db['snippets'].insert('name' => 'header', 'body' => header)

$db['pages'].remove
$db['pages'].insert('path' => '/', 'title' => 'Home', 'body' => home)
$db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => team)
$db['pages'].insert('path' => '/recent-work', 'title' => 'Recent Work', 'body' => recent_work)

$db['team'].remove
%w[Paul Kevin Scott].each do |person|
  $db['team'].insert('name' => person)
end

get '*' do
  route = params[:splat].join('/')

  template = $db['pages'].find(:path => route).first

  halt 404 if template.nil?

  # return template['body']


  @template = Liquid::Template.parse(template['body'])

  assigns = {
    'db' => CollectionDrop.new
  }

  @template.render(assigns)
end