require 'capybara/cucumber'
require 'capybara/rspec'
require 'mongoid'
require 'google/api_client'
require_relative '../../../files/lib/service_account'
require_relative 'drive_helper'
require_relative 'files_helper'
require_relative 'domain_config'

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