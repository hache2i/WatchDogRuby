module Wd
	module Actions
		class GetPendingFilesCount

			def self.do domain, filter
				count = 0
				count = Files::Changed.where(domain: domain).count if filter.nil?
				count = Files::Changed.where(domain: domain).in("oldOwner" => filter["oldOwner"]).count unless filter.nil?
				{ count: count }
			end

		end
	end
end