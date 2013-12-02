@logged
@ignored
Feature: stop scheduled execution
	As a domain administrator
	I want to be able to stop scheduled execution
	So that the permissions does not change automatically

Background:
	Given I am in WatchDog
	And I just saved a config with timing '60'

Scenario: watch if scheduled execution at config screen
	When I click config
	Then I can see if there is an scheduled execution

Scenario: watch if scheduled execution at config screen
	When I click config
	Then I can unschedule the execution

Scenario: watch if scheduled execution at config screen
	When I click config
	And I unschedule the execution
	Then I can see that there is not scheduled execution
