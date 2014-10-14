require 'google/api_client'

require_relative 'service_account'

module Files
  class DriveConnection

    attr_accessor :client, :drive

    def initialize
      @serviceAccount = ServiceAccount.new
      @client = Google::APIClient.new
      @drive = @client.discovered_api('drive', 'v2')
    end

    def authorize user
      @client.authorization = @serviceAccount.authorize(user)
    end

  end
end