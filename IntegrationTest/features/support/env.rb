require 'capybara/cucumber'
require 'capybara/rspec'
require 'mongoid'

# ENV['MONGOID_ENV'] = 'test'
# Mongoid.load! 'config/mongoid.yml', :test

# require File.join(File.dirname(__FILE__), '../../../web/app.rb')

Capybara.default_wait_time = 5
Capybara.default_driver = :selenium

Before do 
  if !$dunit 
    step "Log me in" 
    step "Log me out"
    $dunit = true 
  end 
end 
