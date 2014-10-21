require 'sinatra/base'

module Sinatra
	module Activation
		def require_activation
			if @domain.nil? || !Watchdog::Global::Domains.active?(@domain)
				redirect '/requestActivation'
			end
		end
	end
end