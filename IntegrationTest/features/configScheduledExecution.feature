@logged
@ignored
Feature: config scheduled execution
	As a domain administrator
	I want to configure scheduled executions
	So that I do not have to change the permissions manually

Background:
	Given I am in WatchDog

Scenario: configuration screen
	When I click config
	Then I can see an input for the time
	And I can see an input for the doc's owner

Scenario: save config
	Given I am at config
	When I fill in the timing
	And I fill in the docs owner
	And I save it
	Then I can check the values

Scenario: execution will execute
	Given I just saved a config with timing '1'
	Then docs will be changed after '2'

Scenario: bad arguments timing
	Given I am at config
	When I dont fill in the timing
	And I save it
	Then I see an alert message "You have to specify the timing."

Scenario: bad arguments docsowner
	Given I am at config
	When I dont fill in the docsowner
	And I save it
	Then I see an alert message "You have to specify the docs owner."

