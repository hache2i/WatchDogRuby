@ignored
Feature: no active domain
	As a watchdog admin
	I want that non active domains has no access to dashboard
	So that They can not use the app

Scenario:
	Given the domain is not active
	When I enter in watchdog
	Then I get a page where I can ask for activation