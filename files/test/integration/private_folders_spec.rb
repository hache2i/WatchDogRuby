require 'rspec'
require 'google/api_client'

require_relative '../../lib/service_account'
require_relative '../../lib/private_folders'
require_relative '../../../IntegrationTest/features/support/drive_helper'
require_relative '../../../IntegrationTest/features/support/files_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe 'Private folders' do
	describe "get all folders inside Private" do
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

		it 'finds all' do
			privateFolders = Files::PrivateFolders.new(@serviceAccount, @drive, @client, @user)
			ids = privateFolders.find
			ids.length.should == 2
		end
	end

	describe 'find private folder' do
		before(:all) do
			@client = Google::APIClient.new
			@drive = @client.discovered_api('drive', 'v2')
			@serviceAccount = ServiceAccount.new
			@filesHelper = FilesHelper.new DriveHelper.new(@serviceAccount, @drive, @client)
		end

		it 'raises exception if the user has more than one Private folder' do
			user = DomainConfig.userWithTwoPrivates
			privates = []
			privates << @filesHelper.createPrivateFolder(user)
			privates << @filesHelper.createPrivateFolder(user)
			privateFolders = Files::PrivateFolders.new(@serviceAccount, @drive, @client, user)

			expect{privateFolders.find}.to raise_error(MoreThanOnePrivateFolderException)

			@filesHelper.removeItems(@user, privates)
		end

		it 'finds it if the user has one at the root level' do
			user = 'watchdog@watchdog.h2itec.com'
			id = @filesHelper.createPrivateFolder user
			privateFolders = Files::PrivateFolders.new(@serviceAccount, @drive, @client, user)

			privateFolder = privateFolders.findPrivateFolder
			privateFolder.title.should == 'Private'

			@filesHelper.removeItem(user, id)
		end
	end
end