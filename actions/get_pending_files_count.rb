module Wd
	module Actions
		class GetPendingFilesCount

			def self.do domain
				count = Files::Changed.count_pending domain
				{ count: count }
			end

		end
	end
end