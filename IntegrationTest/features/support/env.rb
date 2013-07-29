require 'capybara/cucumber'
require 'capybara/rspec'

Capybara.default_wait_time = 5
Capybara.default_driver = :selenium

Before do 
  if !$dunit 
    step "Log me in" 
    step "Log me out"
    $dunit = true 
  end 
end 
