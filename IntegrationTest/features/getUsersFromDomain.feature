@wip
Feature: get users from domain
	As a domain administrator
	I Want to get a list of the users
	So that I can list their documents

Background:
	Given I am in WatchDog

Scenario:
	When I search for the users
	Then I get a list of them

