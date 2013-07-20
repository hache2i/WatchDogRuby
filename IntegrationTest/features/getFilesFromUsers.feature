@wip
Feature: get files from users
	As a domain administrator
	I Want to get the files for all users
	So that I can change the permissions

Background:
	Given I got the users list

Scenario:
	When I get the files
	Then I can see a list
