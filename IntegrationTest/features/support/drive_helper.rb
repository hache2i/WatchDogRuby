class DriveHelper

	def initialize(aServiceAccount, aDrive, aClient)
		@serviceAccount = aServiceAccount
		@drive = aDrive
		@client = aClient
	end

	def insert_folder(email, title, description, parentId = nil)
		@client.authorization = @serviceAccount.authorize(email)
		puts 'authorized for insert folder'
		file = fileSchema(title, description, 'application/vnd.google-apps.folder', parentId)
		result = @client.execute(
		    :api_method => @drive.files.insert,
		    :body_object => file)
	  	return manageResult result
	end

	def insert_file(email, title, description, parentId = nil)
		puts 'authorized for insert file'
		@client.authorization = @serviceAccount.authorize(email)
		file = fileSchema(title, description, '', parentId)
		media = Google::APIClient::UploadIO.new(File.join(File.dirname(__FILE__), 'inserted.txt'), '')
	  	result = @client.execute(
		    :api_method => @drive.files.insert,
		    :body_object => file,
		    :media => media,
		    :parameters => {
		      'uploadType' => 'multipart',
		      'alt' => 'json'}
		    )
	  	return manageResult result
	end

	def manageResult(result)
		if result.status == 200
	    	return result.data
	  	else
	  		puts "erroooooooooooooooooooor!"
	  	    puts "An error occurred: #{result.data['error']['message']}"
		    return nil
		end
	end

	def fileSchema(title, description, mime_type, parentId = nil)
		file = @drive.files.insert.request_schema.new({
			    'title' => title,
			    'description' => description,
			    'mimeType' => mime_type
			  })

		if parentId
			file.parents = [{'id' => parentId}]
		end

		file
  	end

	def delete_file(email, file_id)
		@client.authorization = @serviceAccount.authorize(email)
	  result = @client.execute(
	    :api_method => @drive.files.delete,
	    :parameters => { 'fileId' => file_id })
	end

	def delete_files(email, filesIds)
		@client.authorization = @serviceAccount.authorize(email)
		batch = Google::APIClient::BatchRequest.new do |result|
		end
		filesIds.each do |fileId|
			batch.add({
				:api_method => @drive.files.delete,
	    		:parameters => { 'fileId' => fileId }
	    		})
		end
		@client.execute batch
	end
end