@jira-MCF-15 @instances
Feature: Delete an Instance
  As a user, I want to delete instances in my project so that I can free up
  my compute resources.

  From the OpenStack docs (http://goo.gl/JGQGY):
  This operation deletes a specified cloud server instance from the system.

  Background:
    * A project exists in the system
    * The project has 1 active instance


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> an instance in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Can Delete           |
        | Project Manager | Can Delete           |
