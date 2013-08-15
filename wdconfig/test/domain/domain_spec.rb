require 'rspec'

require_relative '../../lib/config_domain'
require_relative '../../lib/timing_not_specified_exception'
require_relative '../../lib/docsowner_not_specified_exception'

describe 'Config Domain' do
	it 'raises timing exception when timing not specified' do
		domain = WDConfig::ConfigDomain.new
		expect{domain.configScheduledExecution('', '', 'docsowner', nil)}.to raise_error TimingNotSpecifiedException
		expect{domain.configScheduledExecution('', '', 'docsowner', '')}.to raise_error TimingNotSpecifiedException
	end
	it 'raises docsowner exception when docsowner not specified' do
		domain = WDConfig::ConfigDomain.new
		expect{domain.configScheduledExecution('', '', '', '1')}.to raise_error DocsownerNotSpecifiedException
		expect{domain.configScheduledExecution('', '', nil, '1')}.to raise_error DocsownerNotSpecifiedException
	end
end