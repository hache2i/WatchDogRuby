@ignored
Feature: active domain
	As a watchdog admin
	I want the active domains to access their dashboard
	So that they can manage their domain configuration

Background:
	Given the domain is active

@logged
Scenario:
	When the admin access the app
	Then the dashboard is presented