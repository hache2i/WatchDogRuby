require_relative '../support/spec_helper'
require_relative '../../../IntegrationTest/features/support/domain_config'

describe "list domain users" do

  before do
    dummy_login
    stub_const("Watchdog::Global::Domains", double(active?: true))
  end

  it 'returns domain users' do
    visit '/domain/users'
    DomainConfig.users.each do |user|
      within("#users") do
        page.should have_css(".user", text: user)
      end
    end
  end

end
