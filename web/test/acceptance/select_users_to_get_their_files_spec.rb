require_relative '../support/spec_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe "select users to get their files" do

  before do
    dummy_login
    stub_const("Watchdog::Global::Domains", stub(active?: true))
  end

  it 'each user record should have a selection checkbox' do
    visit '/domain/users'
    DomainConfig.names.each do |user|
      within("#users") do
        page.should have_css(".user input[type='checkbox']##{user}")
      end
    end
  end

end
