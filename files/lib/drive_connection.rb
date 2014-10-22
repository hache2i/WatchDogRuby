require 'google/api_client'

require_relative 'service_account'

module Files
  class DriveConnection

    attr_accessor :client, :drive

    def initialize
      p "creating Drive Connection"
      @serviceAccount = ServiceAccount.new
      p "initializing client"
      @client = Google::APIClient.new(
        :application_name => 'Watchdog', 
        :application_version => '1.0.0'
      )
      @drive = @client.discovered_api('drive', 'v2')
    end

    def authorize user
      @client.authorization = @serviceAccount.authorize(user)
    end

  end
end