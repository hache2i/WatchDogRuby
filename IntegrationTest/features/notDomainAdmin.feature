@ignored
Feature: get users from domain
	As a domain administrator
	I do not want anybody else to get a list of the documents
	So anybody else can change their permissions

Background:
	Given I am in WatchDog as non admin

Scenario:
	When I search for the users
	Then I see an alert message "You are not a domain administrator."
