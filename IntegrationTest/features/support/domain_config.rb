class DomainConfig

	def self.users
		[
		   'hache2i@watchdog.h2itec.com',
		   'juanperez@sub1.watchdog.h2itec.com',
		   'pepeperez@watchdog.h2itec.com',
		   'joseperez@wdasoc.h2itec.com',
		   'watchdog@watchdog.h2itec.com'
		]
	end

	def self.names
		[
		   'hache2i',
		    'juanperez',
		    'pepeperez',
		    'watchdog',
		    'joseperez'
		]
	end

	def self.names_subset
		[
		   'hache2i',
		    'juanperez'
		]
	end

	def self.users_subset
		[
		   'hache2i@watchdog.h2itec.com',
		    'juanperez@sub1.watchdog.h2itec.com'
		]
	end

	def self.name
		'watchdog.h2itec.com'
	end

	def self.admin
		'hache2i@watchdog.h2itec.com'
	end

	def self.userWithTrashDoc
		'watchdog@watchdog.h2itec.com'
	end

	def self.userWithTwoPrivates
	    'pepeperez@watchdog.h2itec.com'
	end

	def self.totalPublicFiles
		users.length * 3
	end

end