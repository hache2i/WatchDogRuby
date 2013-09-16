require 'rspec'

require_relative '../../lib/user_files_domain'
require_relative '../../../IntegrationTest/features/support/drive_helper'
require_relative '../../../IntegrationTest/features/support/files_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe 'User Files Domain' do

	describe "get user files" do
		before(:all) do
			@client = Google::APIClient.new
			@drive = @client.discovered_api('drive', 'v2')
			@serviceAccount = ServiceAccount.new
			@filesHelper = FilesHelper.new DriveHelper.new(@serviceAccount, @drive, @client)
			@user = DomainConfig.userWithTrashDoc
			@filesHelper.create @user
			@filesHelper.createExtraPrivate @user
		end

		after(:all) do
			@filesHelper.clear
		end

		it 'gets public files and folders' do
			domain = Files::UserFilesDomain.new(@serviceAccount, @client, @drive, @user)
			userFiles = domain.getUserFiles
			userFiles.length.should == 3
			titles = userFiles.to_a.map{|file| file.title}
			titles.include?('Publica').should be_true
			titles.include?('doc in root').should be_true
			titles.include?('doc in public').should be_true
		end
		it 'does not get private files and folders' do
			domain = Files::UserFilesDomain.new(@serviceAccount, @client, @drive, @user)
			userFiles = domain.getUserFiles
			titles = userFiles.to_a.map{|file| file.title}
			titles.include?('Private').should be_false
			titles.include?('doc in private').should be_false
			titles.include?('Folder inside Private').should be_false
			titles.include?('doc in folder inside private').should be_false
		end
		it 'does not get trash files and folders' do
			domain = Files::UserFilesDomain.new(@serviceAccount, @client, @drive, @user)
			userFiles = domain.getUserFiles
			titles = userFiles.to_a.map{|file| file.title}
			titles.include?('doc in trash').should be_false
		end
	end

	describe 'find private folder' do
		before(:all) do
			@client = Google::APIClient.new
			@drive = @client.discovered_api('drive', 'v2')
			@serviceAccount = ServiceAccount.new
			@filesHelper = FilesHelper.new DriveHelper.new(@serviceAccount, @drive, @client)
			@user = DomainConfig.userWithTwoPrivates
			@privates = []
			@privates << @filesHelper.createPrivateFolder(@user)
			@privates << @filesHelper.createPrivateFolder(@user)
		end

		after(:all) do
			@filesHelper.removeItems(@user, @privates)
		end

		it 'raises exception if the user has more than one Private folder' do
			expect{Files::UserFilesDomain.new(@serviceAccount, @client, @drive, @user)}.to raise_error(MoreThanOnePrivateFolderException)
		end

		it 'finds it if the user has one at the root level' do
			user = 'watchdog@watchdog.h2itec.com'
			id = @filesHelper.createPrivateFolder user
			domain = Files::UserFilesDomain.new(@serviceAccount, @client, @drive, user)
			privateFolder = domain.findPrivateFolder
			privateFolder.title.should == 'Private'
			@filesHelper.removeItem(user, id)
		end
	end
end

