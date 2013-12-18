require 'rspec'

require_relative '../../lib/execution_log'

describe 'Execution Log' do
	it 'keeps the last 1000 log records' do
		log = ExecutionLog.new
		(1..1000).each do |index|
			log.add 'message ' + index.to_s
		end
		log.add 'this should be the first message'
		log.records[0].message.should eql 'this should be the first message'
		log.records[log.records.length - 1].message.should eql 'message 2'
	end
end