require_relative '../support/spec_helper'

describe 'non admin user gets error', :wip do
	it 'bla' do
		visit 'http://localhost:3000'
		fill_in 'openid_identifier', :with => 'ideasbrillantes.org'
		click_button 'submit'
		sleep 5
		selector('input#Email').should_not be_nil
		fill_in('Email', :with => 'ehawk')
		fill_in('Passwd', :with => 'lauradelbarrio')
		find('#signIn').click
	end
end