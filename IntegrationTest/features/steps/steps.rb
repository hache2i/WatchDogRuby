Given(/^I am in WatchDog$/) do
  visit 'http://localhost:3000/'
end

Given(/^I got the users list$/) do
  visit 'http://localhost:3000/'
  fill_in('email', :with => 'moore@ideasbrillantes.org')
  fill_in('password', :with => 'olareoun')
  find('#submit').click
end

Given(/^I am logged in as a domain admin user$/) do
  fill_in('email', :with => 'moore@ideasbrillantes.org')
  fill_in('password', :with => 'olareoun')
end

Given(/^I am logged in as a not domain admin user$/) do
  fill_in('email', :with => 'ehawk@ideasbrillantes.org')
  fill_in('password', :with => 'lauradelbarrio')
end

When(/^I search for the users$/) do
  find('#submit').click
end

When(/^I get the files$/) do
  find('#getFiles').click
end

Then(/^I can see an input for my email$/) do
  page.has_css?('#email').should be_true
end

Then(/^I can see an input for my password$/) do
  page.has_css?('#password').should be_true
end

Then(/^I see an alert message "(.*?)"$/) do |alert_message|
  page.has_css?("div.alert").should be_true
  page.find("div.alert").should have_content(alert_message)
end

Then(/^I get a list of them$/) do
  page.all("ul#users li").length.should == 13
  text = page.find('ul#users').text
  text.should include(
    'administrador@ideasbrillantes.org', 'blog@ideasbrillantes.org', 'darwin@ideasbrillantes.org', 'docsadmin@ideasbrillantes.org',
    'ehawk@ideasbrillantes.org', 'fahrenheit@ideasbrillantes.org', 'fuller@ideasbrillantes.org', 'jelices@ideasbrillantes.org',
    'moore@ideasbrillantes.org', 'pitagoras@ideasbrillantes.org', 'redmine@ideasbrillantes.org', 'tesla@ideasbrillantes.org',
    'turing@ideasbrillantes.org') 
end

Then(/^I can see a list$/) do
  page.all("ul#files li").length.should == 1
end

Given(/^I am in the files screen$/) do
  visit 'http://localhost:3000/'
  fill_in('email', :with => 'moore@ideasbrillantes.org')
  fill_in('password', :with => 'olareoun')
  find('#submit').click
  find('#getFiles').click
end

When(/^I change the permissions to "(.*?)"$/) do |user|
  fill_in('newOwner', :with => user)
  find('#changePermissions').click
end

Then(/^all files belong to "(.*?)"$/) do |user|
  page.all("ul#files li").length.should == 184
  page.all("ul#files li span#owner").text.should == 'docsadmin@ideasbrillantes.org'
end

Then(/^I can see a table with files and owners$/) do
  page.all("table#files tr.file-record").length.should == 4
end
