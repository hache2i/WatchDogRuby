require 'rspec'

require_relative '../../lib/user'

describe 'User' do
	it 'returns the email' do
		user = Users::User.new 'victor@cnp.es'
		user.email.should eql 'victor@cnp.es'
	end
	it 'returns the user name' do
		user = Users::User.new 'victor@cnp.es'
		user.name.should eql 'victor'
	end
end