module Users
	class User

		attr_accessor :email

		def initialize(email)
			@email = email
		end

		def name
			extractName @email
		end

		def extractName(email)
			email.scan(/(.+)@(.+)/)[0][0]
		end

	end
end