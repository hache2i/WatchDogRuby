require_relative '../../admin'
require_relative '../support/spec_helper'
require_relative '../support/admin_helper'

describe "List domains in the system" do

  include AdminHelper

	it "button present in admin dashboard" do
		visit '/admin'
		selector('#list-domains').should_not be_nil
	end	
	it "when clicked goes to domains list" do
		visit '/admin'
		selector('#list-domains').click
		current_path.should == '/admin/listDomains'
	end	
	it "when active domain exists it appears with its licenses" do
		activateDomain 'ideasbrillantes.org', 3
		visit '/admin/listDomains'
		within("#domains") do
			within('.domain-record') do
				selector('#licenses').text.should == "3"
			end
		end
	end
	it "when active domain exists it appears with its licenses" do
		activateDomain 'ideasbrillantes.org', 3
		desactivateDomain 'ideasbrillantes.org'
		visit '/admin/listDomains'
		within('#inactive-domains') do
			within('.domain-record') do
				selector('#licenses').text.should == "3"
			end
		end
	end
end