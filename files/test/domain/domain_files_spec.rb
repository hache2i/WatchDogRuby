require 'rspec'

describe 'Domain Files' do
	describe 'to string' do
		it 'when all usersFiles are not empty' do
			domainFiles = Files::DomainFiles.new
			domainFiles.add createUserFiles('mail1')
			domainFiles.add createUserFiles('mail2')

			domainFiles.to_s.should == 'mail1@ideasbrillantes.org#id1,id2-mail2@ideasbrillantes.org#id1,id2'
		end	
		it 'when empty usersFiles' do
			domainFiles = Files::DomainFiles.new
			domainFiles.add createUserFiles('mail1')
			domainFiles.add Files::UserFiles.new 'empty@ideasbrillantes.org'
			domainFiles.add createUserFiles('mail2')

			domainFiles.to_s.should == 'mail1@ideasbrillantes.org#id1,id2-mail2@ideasbrillantes.org#id1,id2'
		end	
	end
end

def createUserFiles(index)
	userFiles = Files::UserFiles.new index + '@ideasbrillantes.org'
	files = []
	files << Files::DriveFile.new('id1', 'title1', ['owner'])
	files << Files::DriveFile.new('id2', 'title2', ['owner'])
	userFiles.addFiles(files)
	userFiles
end