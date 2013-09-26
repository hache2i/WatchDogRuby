require_relative '../support/spec_helper'
require_relative '../support/admin_helper'

describe "Activate Domain by WatchDog Admin" do

  include AdminHelper

  describe "Admin" do
    it "has a way in dashboard to go to activate a domain" do
      visit '/admin'
      selector('a#add-domain').should_not be_nil
    end
    it "can insert the domain" do
      visit "/admin/activateDomain"
      selector('#domain').should_not be_nil
    end
    it "when the domain is added then it is active" do
      activateDomain 'ideasbrillantes.org', 3
      Watchdog::Global::Domains.active?('ideasbrillantes.org').should be_true
    end
    it "and it appears in the domain's list" do
      activateDomain 'ideasbrillantes.org', 3
      visit '/admin/listDomains'
      selector('table#domains').should_not be_nil
      selector('table#domains').text.should include('ideasbrillantes.org')
    end
    it "when the domain is added with licenses" do
      activateDomain 'ideasbrillantes.org', 2
      Watchdog::Global::Domains.licenses('ideasbrillantes.org').should eql 2
    end
    it "when no domain specified we get an error" do
      activateDomain nil
      current_path.should == '/admin/activateDomain'
      selector('.alert').text.should include 'Domain has to be specified.'
    end
    it "when no licenses specified we get an error" do
      activateDomain 'ideasbrillantes.org'
      current_path.should == '/admin/activateDomain'
      selector('.alert').text.should include 'Licenses has to be specified.'
    end
  end

end

def selector string
  find :css, string
end