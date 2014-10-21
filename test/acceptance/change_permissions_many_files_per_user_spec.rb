require_relative '../support/spec_helper'
require_relative '../support/rspec_files_helper'

describe 'changing files permissions ensuring backoff', :js do
	before(:all) do
		@rspec_files_helper = RspecFilesHelper.new
		@rspec_files_helper.create_files 25
		puts "test drive files suite created!!!"
	end

	after(:all) do
		@rspec_files_helper.deleteFilesAdmin
		puts "test drive files suite DELETED!!!"
	end

	before do
		dummy_login
		stub_const("Watchdog::Global::Domains", double(active?: true))
	end

	it 'creates files for users' do
		visit '/domain/users'
		within("#users") do
			find("thead input[type='checkbox']#select_all").click
		end
		find('#getFiles').click
		howManyFiles = page.all('tr.file-record').length
		page.select(DomainConfig.admin, :from => 'newOwner')
		find('#changePermissions').click

		visit '/domain/users'
		within("#users") do
			find("thead input[type='checkbox']#select_all").click
		end
		find('#getFiles').click
		page.all('tr.file-record').length.should == howManyFiles
		page.all("table#files tr.file-record td.owner span").each do |td|
			td.text.should match("Hache2i Estrategia")
		end
	end
end
