require 'rspec'
require 'google/api_client'

require_relative '../../lib/users_domain'

describe 'Users Domain' do

	it 'gets the users' do
		usersDomain = Users::UsersDomain.new
		users = usersDomain.getUsers('moore@ideasbrillantes.org')
		users.include?('administrador@ideasbrillantes.org').should be_true
		users.include?('blog@ideasbrillantes.org').should be_true
		users.include?('darwin@ideasbrillantes.org').should be_true
		users.include?('docsadmin@ideasbrillantes.org').should be_true
		users.include?('ehawk@ideasbrillantes.org').should be_true
		users.include?('fahrenheit@ideasbrillantes.org').should be_true
		users.include?('fuller@ideasbrillantes.org').should be_true
		users.include?('jelices@ideasbrillantes.org').should be_true
		users.include?('moore@ideasbrillantes.org').should be_true
		users.include?('pitagoras@ideasbrillantes.org').should be_true
		users.include?('redmine@ideasbrillantes.org').should be_true
		users.include?('tesla@ideasbrillantes.org').should be_true
		users.include?('turing@ideasbrillantes.org').should be_true
	end
end