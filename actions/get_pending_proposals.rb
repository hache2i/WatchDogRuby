module Wd
	module Actions
		class GetPendingProposals

			def self.do users
			    proposed_change_files = users.inject(Hash.new) do |files, user|
			      user_files = Files::Changed.pending_for_user user
			      files[user] = user_files
			      files
			    end
			    proposed_change_files
			end

		end
	end
end