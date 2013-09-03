require 'rspec'
require 'google/api_client'

require_relative '../../lib/users_domain'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe 'Users Domain' do

	it 'gets the users' do
		usersDomain = Users::UsersDomain.new
		users = usersDomain.getUsers(DomainConfig.admin)
		DomainConfig.users.each do |email|
			users.include?(email).should be_true
		end
	end
end