ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '../../web/app.rb')

require 'rack/test'


RSpec.configure do |config|
  config.mock_with :rspec

  config.before :each do
    Mongoid.purge!
  end
end

def app
  Sinatra::Application
end