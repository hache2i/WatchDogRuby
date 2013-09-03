class FilesHelper

	def initialize(aDriveHelper)
		@driveHelper = aDriveHelper
		@cache = {}
	end

	def create(email)
		folders = []
		files = []

		privateFolderId = @driveHelper.insert_folder(email, 'Private', 'Carpeta Privada')['id']
		privateFileId = @driveHelper.insert_file(email, 'doc in private', '', privateFolderId)['id']

		publicFolderId = @driveHelper.insert_folder(email, 'Publica', 'Carpeta Publica')['id']
		folders << publicFolderId
		files << @driveHelper.insert_file(email, 'doc in public', '', publicFolderId)['id']

		files << @driveHelper.insert_file(email, 'doc in root', '')['id']

		@cache[email] = {:folders => folders, :files => files, :privateFolder => privateFolderId, :privateFile => privateFileId}
	end

	def createExtraPrivate(email)
		privateFolderId = @cache[email][:privateFolder]
		anotherPrivateFolderId = @driveHelper.insert_folder(email, 'Folder inside Private', 'Carpeta Privada Segundo Nivel', privateFolderId)['id']
		@driveHelper.insert_file(email, 'doc in folder inside private', '', anotherPrivateFolderId)['id']
	end

	def clear
		@cache.each_key{|email| remove email}
	end

	def clearWhenChangedPermissionsTo(email)
		puts 'CLEAR ON BEHALF OF'
		@cache.each_key{|email| removePrivate email}
		@driveHelper.delete_files(email, getAllItems)
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

	def removeItems(email, items)
		items.each do |item|
			@driveHelper.delete_file(email, item)
		end
	end

end