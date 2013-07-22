require 'rspec'

require_relative '../../lib/files_domain'

describe 'Files Domain' do
	# describe 'Change Permissions' do
	# 	it 'changes the permissions of the specified files to the specified owner' do
	# 		user1 = 'docsadmin@ideasbrillantes.org'
	# 		user2 = 'ehawk@ideasbrillantes.org'
	# 		domain = Files::FilesDomain.new
	# 		files = domain.getUserFiles user2
	# 		files2 = domain.getUserFiles user1
	# 		puts files2.length
	# 		howMany = files.length
	# 		puts howMany
	# 		domain.changePermissions(createFilesToChange(files), user1)
	# 		domain.getUserFiles(user1).length.should == howMany
	# 	end
	# end

end

def createFilesToChange(files)
	files2Change = []
	ids = []
	files.getFiles.each do |item|
		ids << item.id
	end
	files2Change << {:mail => files.getUser, :ids => ids}
	files2Change
end