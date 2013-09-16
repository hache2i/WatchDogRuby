require 'sinatra/base'

module Sinatra
	module Activation
		def require_activation
			if @domain.nil? || !Watchdog::Global::Domains.active?(@domain)
				redirect '/home'
			end
		end
	end
end