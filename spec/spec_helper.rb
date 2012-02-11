# encoding: UTF-8

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'main'))
require './app'

# We need to explicitly require sinatra as rspec is geared more towards Rails
require 'sinatra'
require 'rspec'
require 'rack/test'

ENV['MONGO_DB'] = "smcms_test"

def app
  @app ||= Sinatra::Application
end

puts "Resetting database..."
$mongo = Mongo::Connection.new
$db = $mongo[ENV['MONGO_DB']]

RSpec.configure do |config|
  config.after(:each) do
    %w[items snippets pages].each {|collection| $db[collection].remove }
  end
end