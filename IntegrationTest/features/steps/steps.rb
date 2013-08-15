When(/^Log me in$/) do
  visit 'http://localhost:3000/'
  fill_in('openid_identifier', :with => 'ideasbrillantes.org')
  find('#submit').click
  fill_in('Email', :with => 'moore')
  fill_in('Passwd', :with => 'olareoun')
  find('#signIn').click
end

When(/^Log me out$/) do
  visit 'http://localhost:3000/logout'
end

Given(/^I am in WatchDog$/) do
  visit 'http://localhost:3000/'
  fill_in('openid_identifier', :with => 'ideasbrillantes.org')
  find('#submit').click
end

Given(/^I am in WatchDog as non admin$/) do
  visit 'http://localhost:3000/'
  fill_in('Email', :with => 'ehawk@ideasbrillantes.org')
  fill_in('Passwd', :with => 'lauradelbarrio')
  find('#signIn').click
  click_button 'Aceptar'
end

Given(/^I got the users list$/) do
  visit 'http://localhost:3000/'
  fill_in('openid_identifier', :with => 'ideasbrillantes.org')
  find('#submit').click
  step "I search for the users"
end

Given(/^I am logged in as a domain admin user$/) do
  fill_in('Email', :with => 'moore@ideasbrillantes.org')
  fill_in('Passwd', :with => 'olareoun')
  find('#signIn').click
  click_button 'Aceptar'
end

Given(/^I am logged in as a not domain admin user$/) do
  fill_in('Email', :with => 'ehawk@ideasbrillantes.org')
  fill_in('Passwd', :with => 'lauradelbarrio')
  find('#signIn').click
  click_button 'Aceptar'
end

When(/^I search for the users$/) do
  find('#submit').click
end

When(/^I get the files$/) do
  find('#getFiles').click
end

Then(/^I can see an input for my email$/) do
  page.has_css?('#Email').should be_true
end

Then(/^I can see an input for my password$/) do
  page.has_css?('#Passwd').should be_true
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

Given(/^I got several files from several users$/) do
  page.all("table#files tr.file-record").length.should > 0
end

When(/^I change the permissions to "(.*?)"$/) do |user|
  page.select(user, :from => 'newOwner')
  fill_in('newOwnerHidden', :with => user)
  find('#changePermissions').click
end

Then(/^all files belong to "(.*?)"$/) do |user|
  page.all("ul#files li").length.should == 184
  page.all("ul#files li span#owner").text.should == user
end

Then(/^I can see a table with files and owners$/) do
  page.all("table#files tr.file-record").length.should == 4
end

Then(/^I can select the future owner among domain users$/) do
  page.all("select#newOwner option").length.should == 13
  text = page.find('select#newOwner').text
  text.should include(
    'administrador@ideasbrillantes.org', 'blog@ideasbrillantes.org', 'darwin@ideasbrillantes.org', 'docsadmin@ideasbrillantes.org',
    'ehawk@ideasbrillantes.org', 'fahrenheit@ideasbrillantes.org', 'fuller@ideasbrillantes.org', 'jelices@ideasbrillantes.org',
    'moore@ideasbrillantes.org', 'pitagoras@ideasbrillantes.org', 'redmine@ideasbrillantes.org', 'tesla@ideasbrillantes.org',
    'turing@ideasbrillantes.org') 
end

Then(/^I can not see trash documents$/) do
  page.find("table#files").text.should_not match('Doc in Trash')
end

When(/^I click config$/) do
  find('#config').click
end

Then(/^I can see an input for the time$/) do
  page.has_css?('input#timing').should be_true
end

Then(/^I can see an input for the doc's owner$/) do
  page.has_css?('input#newOwner').should be_true
end

Given(/^I am at config$/) do
  step "I click config"
end

When(/^I fill in the timing$/) do
  fill_in('timing', :with => '60')
end

When(/^I fill in the docs owner$/) do
  fill_in('newOwner', :with => 'docsadmin@ideasbrillantes.org')
end

When(/^I save it$/) do
  find('#save').click
end

Then(/^I can check the values$/) do
  visit "http://localhost:3000/config"
  find('input#timing').value.should == "60"
  find('input#newOwner').value.should == "docsadmin@ideasbrillantes.org"
end

Given(/^I just saved a config with timing '(\d+)'$/) do |arg1|
  step "I click config"
  fill_in('timing', :with => arg1)
  fill_in('newOwner', :with => 'docsadmin@ideasbrillantes.org')
  step "I save it"
end

Then(/^docs will be changed after '(\d+)'$/) do |arg1|
  sleep(arg1.to_i * 60 * 2)
  step "I search for the users"
  step "I get the files"
  page.all("table#files tr.file-record td.owner").length.should == 4
  page.all("table#files tr.file-record td.owner span").each do |td|
    td.text.should == "Docs Owner"
  end
end

When(/^I dont fill in the timing$/) do
  fill_in('newOwner', :with => 'docsadmin@ideasbrillantes.org')
end

When(/^I dont fill in the docsowner$/) do
end

Given(/^I have configured an scheduled execution$/) do
  step 'I just saved a config with timing "60"'
end

Then(/^I can see if there is an scheduled execution$/) do
  page.has_css?('a#unschedule').should be_true
end

Then(/^I can unschedule the execution$/) do
  page.has_css?('a#unschedule').should be_true
end

When(/^I unschedule the execution$/) do
  page.find('#unschedule').click
end

Then(/^I can see that there is not scheduled execution$/) do
  page.has_css?('a#unschedule').should be_false
end
