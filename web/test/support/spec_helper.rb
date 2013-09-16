ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara-webkit'
require 'bundler/setup'

Capybara.app = eval "Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../../../config.ru') + "\n )}"
Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :each do
  	Watchdog::Global::Domains.clear
    Mongoid.purge!
  end

  # config.after :each do
  # 	Watchdog::Global::Domains.clear
  #   Mongoid.purge!
  # end

  config.include Capybara::DSL

  config.treat_symbols_as_metadata_keys_with_true_values = true

  include Rack::Test::Methods

end

