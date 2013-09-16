require_relative '../../admin'
require_relative '../support/spec_helper'

describe "List domains in the system" do
	it "button present in admin dashboard" do
		visit '/admin'
		selector('#list-domains').should_not be_nil
	end	
	it "when clicked goes to domains list" do
		visit '/admin'
		selector('#list-domains').click
		current_path.should == '/admin/listDomains'
	end	
end