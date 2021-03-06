class FilesHelper

	def initialize(aDriveHelper)
		@driveHelper = aDriveHelper
		@cache = {}
	end

	def create(email, publicFilesNumber = nil)
		puts "creating drive files test suite for " + email
		publicFilesNumber ||= 1
		folders = []
		files = []

		privateFolderId = @driveHelper.insert_folder(email, 'Private', 'Carpeta Privada')['id']
		privateFileId = @driveHelper.insert_file(email, 'doc in private', '', privateFolderId)['id']

		@publicFolder = @driveHelper.insert_folder(email, 'Publica', 'Carpeta Publica')
		publicFolderId = @publicFolder['id']
		folders << publicFolderId

		files.concat(@driveHelper.insert_files(email, 'doc in public', '', publicFilesNumber, publicFolderId))

		files << @driveHelper.insert_file(email, 'doc in root', '')['id']

		@cache[email] = {:folders => folders, :files => files, :privateFolder => privateFolderId, :privateFile => privateFileId}
	end

	def getPublicFolder
		@publicFolder
	end

	def createExtraPrivate(email)
		privateFolderId = @cache[email][:privateFolder]
		anotherPrivateFolderId = @driveHelper.insert_folder(email, 'Folder inside Private', 'Carpeta Privada Segundo Nivel', privateFolderId)['id']
		@driveHelper.insert_file(email, 'doc in folder inside private', '', anotherPrivateFolderId)
	end

	def clear
		@cache.each_key{|email| remove email}
	end

	def clearWhenChangedPermissionsTo(email)
		puts 'CLEAR ON BEHALF OF'
		@cache.each_key{|email| removePrivate email}
		@driveHelper.delete_files(email, getAllItems)
	end

	def createPrivateFolder(email)
		@driveHelper.insert_folder(email, 'Private', 'Carpeta Privada')['id']
	end

	def removeItems(email, items)
		items.each do |item|
			puts 'filesHelper removeItems'
			@driveHelper.delete_file(email, item)
		end
	end

	def removeItem(email, item)
		@driveHelper.delete_file(email, item)
	end

	def getCache
		@cache
	end

	private

	def getAllItems
		items = []
		@cache.each_value{|value| items.concat value[:files]}
		@cache.each_value{|value| items.concat value[:folders]}
		items
	end

	def remove(email)
		itemsToRemove = []
		itemsToRemove.concat @cache[email][:files]
		itemsToRemove.concat @cache[email][:folders]
		itemsToRemove << @cache[email][:privateFile]
		itemsToRemove << @cache[email][:privateFolder]
		@driveHelper.delete_files(email, itemsToRemove)
	end

	def removePrivate(email)
		@driveHelper.delete_file(email, @cache[email][:privateFile])
		@driveHelper.delete_file(email, @cache[email][:privateFolder])
	end

end