module Watchdog
	module Global
		module Logs
			module Execution
				extend self

				def add msg, domain = nil, user = nil, level = nil
					log.add msg, domain, user, level
				end

				def get
					log
				end

				private

				def log
					@exec_log ||= init
					@exec_log
				end

				def init
					ExecutionLog.new
				end

			end
		end
	end
end