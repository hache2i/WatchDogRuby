require_relative '../../../files/lib/service_account'
require_relative '../../../IntegrationTest/features/support/drive_helper'
require_relative '../../../IntegrationTest/features/support/files_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

class RspecFilesHelper

	def initialize
	  client = Google::APIClient.new
	  drive = client.discovered_api('drive', 'v2')
	  @filesHelper = FilesHelper.new DriveHelper.new(ServiceAccount.new, drive, client)
	end

	def create_files howMany
	  DomainConfig.users_subset.each do |email|
	    @filesHelper.create email, howMany
	  end
	end

	def delete_files
		@filesHelper.clear
	end

	def deleteFilesAdmin
	  @filesHelper.clearWhenChangedPermissionsTo DomainConfig.admin
	end
end