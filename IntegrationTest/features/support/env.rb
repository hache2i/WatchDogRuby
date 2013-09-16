require 'capybara/cucumber'
require 'capybara/rspec'
require 'mongoid'
require 'google/api_client'
require_relative '../../../files/lib/service_account'
require_relative 'drive_helper'
require_relative 'files_helper'
require_relative 'domain_config'

ENV['RACK_ENV'] = 'test'
 
Capybara.default_wait_time = 5
Capybara.default_driver = :selenium
Capybara.javascript_driver = :webkit

# Before do 
#   step "The domain is active"
# end 

Before('@logged') do 
  if !$dunit 
    step "Log me in" 
    step "Log me out"
    $dunit = true 
  end 
end 

Before('@createFiles') do
  client = Google::APIClient.new
  drive = client.discovered_api('drive', 'v2')
  @filesHelper = FilesHelper.new DriveHelper.new(ServiceAccount.new, drive, client)
  DomainConfig.users.each do |email|
    @filesHelper.create email
  end
end

After('@deleteFiles') do
	@filesHelper.clear
end

After('@deleteFilesAdmin') do
  @filesHelper.clearWhenChangedPermissionsTo DomainConfig.admin
end