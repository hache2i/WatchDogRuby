require 'rspec'
require 'google/api_client'

require_relative '../../lib/users_domain'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe 'Users Domain' do

	it 'gets the users' do
		usersDomain = Users::UsersDomain.new
		users = usersDomain.getUsers(DomainConfig.admin).map(&:email)
		DomainConfig.users.each do |email|
			users.include?(email).should be_true
		end
	end

	it 'returns true if user is admin' do
		usersDomain = Users::UsersDomain.new
		usersDomain.isAdmin(DomainConfig.admin).should be_true
	end

	it 'returns false if user is not admin' do
		usersDomain = Users::UsersDomain.new
		usersDomain.isAdmin('pepeperez@watchdog.h2itec.com').should be_false
	end
end