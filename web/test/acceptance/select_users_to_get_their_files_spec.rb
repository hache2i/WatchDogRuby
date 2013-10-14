require_relative '../support/spec_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe "select users to get their files", :wip, :js do

  before do
    dummy_login
    stub_const("Watchdog::Global::Domains", double(active?: true))
  end

  it 'each user record should have a selection checkbox' do
    visit '/domain/users'
    DomainConfig.names.each do |user|
      within("#users") do
        page.should have_css(".user input[type='checkbox']##{user}")
      end
    end
  end

  describe "Select All" do
    it 'there is a checkbox to select all users' do
      visit '/domain/users'
      within("#users") do
        page.should have_css("thead input[type='checkbox']#select_all")
      end
    end
    it 'when clicked all the checkboxes are selected' do
      visit '/domain/users'
      within("#users") do
        find("thead input[type='checkbox']#select_all").click
      end
      page.all(".user input[type='checkbox']").each do |checkbox|
        checkbox.should be_checked
      end
    end
  end

end
