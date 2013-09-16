require 'rspec'
require_relative '../../lib/domains_status'
require_relative '../../../web/test/support/spec_helper'

describe 'global domains' do
	before :each do
		@domains = WDAdmin::DomainsStatus.new
	end
	it 'domain not active if it was not added' do
		@domains.active?('ideasbrillantes.org').should be_false
	end
	it 'domain active if it was added' do
		@domains.activate('ideasbrillantes.org')
		@domains.active?('ideasbrillantes.org').should be_true
	end
	it 'clears the domains' do
		@domains.activate('ideasbrillantes.org')
		@domains.active?('ideasbrillantes.org').should be_true
		@domains.clear
		@domains.active?('ideasbrillantes.org').should be_false
	end
	it 'desactivates a domain' do
		@domains.activate('ideasbrillantes.org')
		@domains.active?('ideasbrillantes.org').should be_true
		@domains.desactivate('ideasbrillantes.org')
		@domains.active?('ideasbrillantes.org').should be_false
	end
	it 'after desactivation it is in the inactive list' do
		@domains.activate('ideasbrillantes.org')
		@domains.desactivate('ideasbrillantes.org')
		@domains.inactive.include?('ideasbrillantes.org').should be_true
	end
	it 'when activation-desactivation-reactivation it is not in the inactive list' do
		@domains.activate('ideasbrillantes.org')
		@domains.desactivate('ideasbrillantes.org')
		@domains.activate('ideasbrillantes.org')
		@domains.inactive.include?('ideasbrillantes.org').should be_false
	end
end