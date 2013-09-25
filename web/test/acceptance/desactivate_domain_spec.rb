require_relative '../../admin'
require_relative '../support/spec_helper'
require_relative '../support/admin_helper'
require_relative '../../../wdconfig/lib/config_domain'

describe 'Desactivate Domain by WatchDog Admin', :js do
	include AdminHelper

	# describe 'authorize' do
	# 	it 'can authorize the test' do
	# 		basic_auth 'foo', 'bar'
	# 		# visit '/admin/listDomains'
	# 		# selector('#domains').should_not be_nil
	# 	visit "/admin/activateDomain"
	# 		selector('#domain').should_not be_nil
	# 	# fill_in 'domain', :with => 'ideasbrillantes.org'
	# 	# selector('button#add-domain').click
	# 		# selector('#add-domain').should_not be_nil
	# 		# selector('#add-domain').click
	# 		# get '/admin'
	# 		# last_response.status.should == 200
	# 	end
	# end

	describe 'Admin' do
		before :each do
			activateDomain 'ideasbrillantes.org'
			# basic_auth 'foo', 'bar'
		end
		it 'can desactivate a domain from domains list' do
			visit '/admin/listDomains'
			selector('table#domains tr.domain-record td a#desactivate').should_not be_nil
		end	
		it 'should be inactive if it is desactivated' do
			visit '/admin/listDomains'
			selector('table#domains tr.domain-record td a#desactivate').click
			sleep 1
			Watchdog::Global::Domains.active?('ideasbrillantes.org').should be_false
		end
		it 'after desactivation should redirect to list domains' do
			visit '/admin/listDomains'
			selector('table#domains tr.domain-record td a#desactivate').click
			current_path.should == "/admin/listDomains"
		end
		it 'after desactivation the domain should be in the desactivated domains list' do
			visit '/admin/listDomains'
			selector('table#domains tr.domain-record td a#desactivate').click
		    selector('table#inactive-domains').text.should include('ideasbrillantes.org')
		end
		it 'after desactivation the domain should not have scheduled execution' do
			configDomain = WDConfig::ConfigDomain.new
			configDomain.configScheduledExecution('ideasbrillantes.org', 'moore@ideasbrillantes.org', 'docsowner@ideasbrillantes.org', '1000')
			visit '/admin/listDomains'
			selector('table#domains tr.domain-record td a#desactivate').click
			find('#domains')
			configDomain.getScheduledExecution('ideasbrillantes.org').scheduled?.should be_false
		end
	end
end

def app
	Capybara.app
end

