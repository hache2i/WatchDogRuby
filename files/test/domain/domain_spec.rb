require 'rspec'

require_relative '../../lib/files_domain'
require_relative '../../lib/service_account'

describe 'Files Domain' do
	describe 'Change Permissions' do
		it 'changes the permissions of the specified files to the specified owner' do
			domain = Files::FilesDomain.new
			files = domain.getUserFiles 'docsadmin@ideasbrillantes.org'
			howMany = files.length
			domain.changePermissions(createFilesToChange(files), 'ehawk@ideasbrillantes.org')
			domain.getUserFiles('ehawk@ideasbrillantes.org').length.should == howMany
		end
	end

	describe 'Get User Files' do
		it 'retrieves the user files' do
			domain = Files::FilesDomain.new
			userFiles = domain.getUserFiles('moore@ideasbrillantes.org')
			userFiles.getUser.should == 'moore@ideasbrillantes.org'
			userFiles.length.should_not == 0
		end
	end
end

def createFilesToChange(files)
	files2Change = []
	files.getFiles.each do |item|
		files2Change << {:mail => files.getUser, :id => item.id}
	end
	files2Change
end