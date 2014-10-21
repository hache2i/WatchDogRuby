ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara-webkit'
require 'bundler/setup'
require 'google/api_client'

Capybara.app = eval "Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../../../config.ru') + "\n )}"
Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :each do
  	Watchdog::Global::Domains.clear
    Mongoid.purge!
  end

  config.include Capybara::DSL

  config.treat_symbols_as_metadata_keys_with_true_values = true

end

def dummy_login
  Web.any_instance.stub(:authenticated?).and_return(true)
  Web.any_instance.stub(:get_domain).and_return('watchdog.h2itec.com')
  Web.any_instance.stub(:get_user_email).and_return('hache2i@watchdog.h2itec.com')
end

def selector string
  find :css, string
end

