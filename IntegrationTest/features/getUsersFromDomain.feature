Feature: get users from domain
	As a domain administrator
	I Want to get a list of the users
	So that I can list their documents

Background:
	Given I am in WatchDog

Scenario:
	Then I can see an input for my email
	And I can see an input for my password

Scenario:
	Given I am logged in as a domain admin user
	When I search for the users
	Then I get a list of them

Scenario:
	Given I am logged in as a not domain admin user
	When I search for the users
	Then I see an alert message "You are not a domain administrator."
