require 'mongoid'
require_relative 'log_record'

class DbExecutionLog

    include Mongoid::Document
    include Mongoid::Timestamps::Created

    field :user, :type => String
    field :domain, :type => String
    field :message, :type => String
    field :when, :type => String

	MAX_RECORDS = 10000
	DEFAULT_LEVELS = [:info, :error]
	PAGE_SIZE = 25


	def self.add(message, domain = nil, user = nil, level = nil)
		log_record = LogRecord.new(message, domain, user, level)
		create log_record.to_hash
	end

	def self.get debug
		p "looking for records from scratch #{debug.to_s}"

    levels = DEFAULT_LEVELS.clone
    levels << :debug if debug

    total_at_time = self.in(level: levels).desc(:when).count
    records = self.in(level: levels).desc(:when).limit(PAGE_SIZE)
    { records: records, total_at_time: total_at_time, from_scratch: true }
  end

  def self.get_from from, total_at_time, debug
    p "looking for records from #{from} of #{total_at_time} absolute total"
    restart = from >= total_at_time
    return get if restart

    levels = DEFAULT_LEVELS.clone
    levels << :debug if debug

		total_now = self.in(level: levels).desc(:when).count
		records = self.in(level: levels).desc(:when).skip(total_now - total_at_time + from).limit(PAGE_SIZE)

		{ records: records, total_at_time: total_at_time }
	end

end