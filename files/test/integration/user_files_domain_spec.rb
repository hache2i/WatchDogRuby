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
			userFiles.to_s.should match('0BxHIjVQxg2FeOVRCdmRqc3JvQlU')
		end
		it 'does not get private files and folders' do
			domain = Files::UserFilesDomain.new(serviceAccount, client, drive, 'moore@ideasbrillantes.org')
			userFiles = domain.getUserFiles
			userFiles.to_s.should_not match('0BxHIjVQxg2FeNWZ3UE95d2lyR2M')
			userFiles.to_s.should_not match('16hpKNvkkoBw3WVt_sfvNv3_6EqAlSTo2IogEkNGFXb0')
			userFiles.to_s.should_not match('1GjDUqbxgaLJ5Xq2nC-QwqjyfI9TAtD6Y2cuo7iZNmBA')
			userFiles.to_s.should_not match('0BxHIjVQxg2FeNHFhTVRGd256WFE')
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