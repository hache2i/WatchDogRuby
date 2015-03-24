require_relative 'log_record'

class ExecutionLog

	attr_accessor :records

	MAX_RECORDS = 10000
	DEFAULT_LEVELS = [:info, :error, :debug]
	PAGE_SIZE = 25


	def initialize
		@records = []
	end

	def add(message, domain = nil, user = nil, level = nil)
		@records.unshift LogRecord.new(message, domain, user, level)
		#@records.pop if @records.length > MAX_RECORDS
	end

	def get
		p "looking for records from scratch #{records.count}"
		selected = records.select { |record| DEFAULT_LEVELS.include? record.level }
		total_at_time = selected.size
		records = selected.take PAGE_SIZE
		{ records: records, total_at_time: total_at_time, from_scratch: true }
	end

	def get_from from, total_at_time
		p "looking for records from #{from} of #{total_at_time} absolute total #{records.count}"
		restart = from >= total_at_time
		return get if restart
		selected = records.select { |record| DEFAULT_LEVELS.include? record.level }
		records = selected.slice selected.size - total_at_time + from, PAGE_SIZE
		{ records: records, total_at_time: total_at_time }
	end

end