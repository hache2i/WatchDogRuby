require_relative 'log_record'

class ExecutionLog

	attr_accessor :records

	MAX_RECORDS = 10000

	def initialize
		@records = []
	end

	def add(message, domain = nil, user = nil, level = nil)
		@records.push LogRecord.new(message, domain, user, level)
		@records.shift if @records.length > MAX_RECORDS
	end

end