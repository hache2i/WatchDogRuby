require 'rspec'
require_relative '../../lib/user_files'

describe 'User Files' do
	it 'created with user email' do
		userFiles = Files::UserFiles.new 'moore@ideasbrillantes.org'
		userFiles.getUser.should == 'moore@ideasbrillantes.org'
	end
	it 'files can be added' do
		userFiles = Files::UserFiles.new 'moore@ideasbrillantes.org'

		files = []
		files << Files::DriveFile.new('id1', 'title1', ['owners1'])
		files << Files::DriveFile.new('id2', 'title2', ['owners2'])

		userFiles.addFiles(files)

		userFiles.length.should == 2
	end
	describe 'to string' do
		it 'when has files' do
			userFiles = Files::UserFiles.new 'moore@ideasbrillantes.org'

			files = []
			files << Files::DriveFile.new('id1', 'title1', ['owners1'])
			files << Files::DriveFile.new('id2', 'title2', ['owners2'])

			userFiles.addFiles(files)

			userFiles.to_s.should == 'moore@ideasbrillantes.org#id1,id2'
		end
		it 'when no files' do
			userFiles = Files::UserFiles.new 'moore@ideasbrillantes.org'

			userFiles.to_s.should == ''
		end
	end
end