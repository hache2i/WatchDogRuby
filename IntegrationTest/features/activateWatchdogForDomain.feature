@logged
@ignored
Feature: activate watchdog for domain
	As a watchdog admin
	I want to activate the app for a domain
	So that the domain admin can access his dashboard

Background:
	Given I am in the admin module

Scenario:
	When I activate a domain
	Then the admin can access to his dashboard