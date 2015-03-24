require_relative 'db_execution_log'

module Watchdog
	module Global
		module Logs
			module Execution
				extend self

				def add msg, domain = nil, user = nil, level = nil
					log.add msg, domain, user, level
				end

				def get
					log.get
				end

				def get_from from, total_at_time
					log.get_from from, total_at_time
				end

				private

				def log
					@exec_log ||= init
					@exec_log
				end

				def init
					p "initialize execution log"
					# ExecutionLog.new
					DbExecutionLog
				end

			end
		end
	end
end