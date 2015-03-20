module Watchdog
	module Global
		module Logs
			module Execution
				extend self

				DEFAULT_LEVELS = [:info, :error, :debug]
				PAGE_SIZE = 25

				def add msg, domain = nil, user = nil, level = nil
					log.add msg, domain, user, level
				end

				def get
					selected = log.records.select { |record| DEFAULT_LEVELS.include? record.level }
					count = selected.size
					records = selected.take PAGE_SIZE
					{ records: records, count: count }
				end

				def get_from from, count
					p "looking for records"
					p from
					p count
					restart = from >= count
					return get if restart
					selected = log.records.select { |record| DEFAULT_LEVELS.include? record.level }
					p selected.size
					p selected.size - count + from
					records = selected.slice selected.size - count + from, PAGE_SIZE
					{ records: records, count: count }
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