module Watchdog
	module Global
		module Logs
			module Execution
				extend self

				DEFAULT_LEVELS = [:info, :error, :debug]
				PAGE_SIZE = 100

				def add msg, domain = nil, user = nil, level = nil
					log.add msg, domain, user, level
				end

				def get
					selected = log.records.select { |record| DEFAULT_LEVELS.include? record.level }
					selected.take PAGE_SIZE
				end

				def get_from from
					selected = log.records.select { |record| DEFAULT_LEVELS.include? record.level }
					selected.slice from, PAGE_SIZE
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