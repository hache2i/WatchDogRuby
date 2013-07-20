Feature: change files owner
	As a domain administrator
	I want to change the owner of all domain drive files to a specific user
	So that they belong to that user

Background:
	Given I am in the files screen

Scenario:
	When I change the permissions to "docsadmin@ideasbrillantes.org"
	Then all files belong to "docsadmin@ideasbrillantes.org"