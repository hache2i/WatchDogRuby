module Watchdog
	module Global
		module Logs
			module Execution
				extend self

				DEFAULT_LEVELS = [:info, :error, :debug]
				PAGE_SIZE = 25

				def add msg, domain = nil, user = nil, level = nil
					users = ""
					users = user.join(", ") unless user.nil?
					log.add msg, domain, user.join(", "), level
				end

				def get
					p "looking for records from scratch #{log.records.count}"
					selected = log.records.select { |record| DEFAULT_LEVELS.include? record.level }
					total_at_time = selected.size
					records = selected.take PAGE_SIZE
					{ records: records, total_at_time: total_at_time, from_scratch: true }
				end

				def get_from from, total_at_time
					p "looking for records from #{from} of #{total_at_time} absolute total #{log.records.count}"
					restart = from >= total_at_time
					return get if restart
					selected = log.records.select { |record| DEFAULT_LEVELS.include? record.level }
					records = selected.slice selected.size - total_at_time + from, PAGE_SIZE
					{ records: records, total_at_time: total_at_time }
				end

				private

				def log
					@exec_log ||= init
					@exec_log
				end

				def init
					p "initialize execution log"
					ExecutionLog.new
				end

			end
		end
	end
end