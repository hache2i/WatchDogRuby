require 'rspec'

require_relative '../../lib/execution_configurations'
require_relative '../../lib/execution_configuration'

require_relative '../../../test/support/spec_helper'

describe 'Execution Configurations' do
	it 'is empty when created' do
		configs = WDConfig::ExecutionConfigurations.new
		configs.empty?.should be_true
	end
	it 'stores execution configuration and then it is not empty' do
		configs = WDConfig::ExecutionConfigurations.new
		config = WDConfig::ExecutionConfiguration.new(domain: 'ib.org', admin: 'adminib', docsOwner: 'ownerib', timing: 1, scheduled: true)
		configs.store(config)
		configs.empty?.should be_false
	end
	it 'can find config for domain' do
		configs = WDConfig::ExecutionConfigurations.new
		config = WDConfig::ExecutionConfiguration.new(domain: 'ib.org', admin: 'adminib', docsOwner: 'ownerib', timing: 1, scheduled: true)
		configs.store(config)
		config = configs.get('ib.org')
		config.getTiming.should == 1
		config.getDocsOwner.should == 'ownerib'
	end
	it 'stores several configurations and retrieves them by domain' do
		configs = WDConfig::ExecutionConfigurations.new
		configs.store(WDConfig::ExecutionConfiguration.new(domain: 'ib.org', admin: 'adminib', docsOwner: 'ownerib', timing: 1, scheduled: true))
		configs.store(WDConfig::ExecutionConfiguration.new(domain: 'h2i.es', admin: 'adminh2i', docsOwner: 'ownerh2i', timing: 33, scheduled: true))
		config = configs.get('ib.org')
		config.getTiming.should == 1
		config.getDocsOwner.should == 'ownerib'
		config = configs.get('h2i.es')
		config.getTiming.should == 33
		config.getDocsOwner.should == 'ownerh2i'
	end
end