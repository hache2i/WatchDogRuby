Feature: get files from users
	As a domain administrator
	I Want to get the files for all users
	So that I can change the permissions

Background:
	Given I got the users list

Scenario: Get public files
	When I get the files
	Then I can see a table with files and owners

@wip
Scenario: Get public files
	When I get the files
	Then I can not see trash documents

Scenario: Owner selection
	When I get the files
	Then I can select the future owner among domain users
