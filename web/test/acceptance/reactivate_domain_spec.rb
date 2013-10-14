require_relative '../../admin'
require_relative '../support/spec_helper'
require_relative '../support/admin_helper'

describe 'Reactivate Domain by WatchDog Admin' do
	include AdminHelper

	before do
		activateDomain 'ideasbrillantes.org', 3
		visit '/admin/listDomains'
		find('table#domains tr.domain-record td#actions a#desactivate').click
	end

	it 'can be reactivated' do
		visit '/admin/listDomains'
		find('table#inactive-domains tr.domain-record td#actions a#activate').should_not be_nil
	end

	it 'when reactivated it is active' do
		visit '/admin/listDomains'
		find('table#inactive-domains tr.domain-record td#actions a#activate').click
		sleep 1
		Watchdog::Global::Domains.active?('ideasbrillantes.org').should be_true
	end

	it 'after reactivation should redirect to domains list' do
		visit '/admin/listDomains'
		find('table#inactive-domains tr.domain-record td#actions a#activate').click
		current_path.should == "/admin/listDomains"
	end

	it 'when reactivated it appears in the active list' do
		visit '/admin/listDomains'
		find('table#inactive-domains tr.domain-record td#actions a#activate').click
		visit '/admin/listDomains'
		find('table#domains').text.should include('ideasbrillantes.org')
	end
end