require 'rspec'

require_relative '../../lib/user_files_domain'

describe 'User Files Domain' do

	let(:serviceAccount) {ServiceAccount.new}
	let(:client) {Google::APIClient.new}
	let(:drive) {client.discovered_api('drive', 'v2')}

	describe "get user files" do
		it 'gets public files and folders' do
			domain = Files::UserFilesDomain.new(serviceAccount, client, drive, 'moore@ideasbrillantes.org')
			userFiles = domain.getUserFiles
			userFiles.length.should == 4
			titles = userFiles.to_a.map{|file| file.title}
			titles.include?('Doc Pub A In Root').should be_true
			titles.include?('Doc Pub B In Root').should be_true
			titles.include?('Public Folder A').should be_true
			titles.include?('Doc Pub A In Folder A').should be_true
		end
		it 'does not get private files and folders' do
			domain = Files::UserFilesDomain.new(serviceAccount, client, drive, 'moore@ideasbrillantes.org')
			userFiles = domain.getUserFiles
			titles = userFiles.to_a.map{|file| file.title}
			titles.include?('Private').should be_false
			titles.include?('NoVisibleFolderDeph1').should be_false
			titles.include?('NoVisibleFolderDeph2').should be_false
			titles.include?('docnovisible1').should be_false
			titles.include?('docnovisibledeph2').should be_false
			titles.include?('drawnovisible1').should be_false
		end
	end

	describe 'find private folder' do
		it 'raises exception if the user has more than one Private folder' do
			expect{Files::UserFilesDomain.new(serviceAccount, client, drive, 'turing@ideasbrillantes.org')}.to raise_error(MoreThanOnePrivateFolderException)
		end
		it 'finds it if the user has one at the root level' do
			domain = Files::UserFilesDomain.new(serviceAccount, client, drive, 'moore@ideasbrillantes.org')
			privateFolder = domain.findPrivateFolder
			privateFolder.title.should == 'Private'
		end
	end
end