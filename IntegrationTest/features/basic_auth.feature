Feature: Basic Auth in module admin

Scenario:
	Given I do a basic auth
	When I go to admin
	Then I see the buttons