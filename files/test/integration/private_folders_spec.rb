require 'rspec'
require 'google/api_client'

require_relative '../../lib/service_account'
require_relative '../../lib/private_folders'
require_relative '../../../IntegrationTest/features/support/drive_helper'
require_relative '../../../IntegrationTest/features/support/files_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe 'Private folders' do

	describe 'on load' do
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

			expect{privateFolders.load}.to raise_error(MoreThanOnePrivateFolderException)

			@filesHelper.removeItems(@user, privates)
		end

	end

	describe "isPrivate" do
		before(:all) do
			@client = Google::APIClient.new
			@drive = @client.discovered_api('drive', 'v2')
			@serviceAccount = ServiceAccount.new
			@filesHelper = FilesHelper.new DriveHelper.new(@serviceAccount, @drive, @client)
			@user = DomainConfig.userWithTrashDoc
			@filesHelper.create @user
			@docInFolderInsidePrivate = @filesHelper.createExtraPrivate @user
		end

		after(:all) do
			@filesHelper.clear
		end

		it 'knows if a file is inside Private hierarchy' do
			privateFolders = Files::PrivateFolders.new(@serviceAccount, @drive, @client, @user)
			privateFolders.load
			privateFolders.isPrivate(@docInFolderInsidePrivate).should be_true
		end

		it 'knows if a file is not inside Private hierarchy' do
			privateFolders = Files::PrivateFolders.new(@serviceAccount, @drive, @client, @user)
			privateFolders.load
			privateFolders.isPrivate(@filesHelper.getPublicFolder).should be_false
		end
	end

end