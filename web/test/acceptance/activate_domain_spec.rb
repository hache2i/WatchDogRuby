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
      visit "/admin/activateDomain"
      fill_in 'domain', :with => 'ideasbrillantes.org'
      selector('button#add-domain').click
      Watchdog::Global::Domains.active?('ideasbrillantes.org').should be_true
    end
    it "and it appears in the domain's list" do
      activateDomain 'ideasbrillantes.org'
      visit '/admin/listDomains'
      selector('table#domains').should_not be_nil
      selector('table#domains').text.should include('ideasbrillantes.org')
    end

  end

end

def selector string
  find :css, string
end