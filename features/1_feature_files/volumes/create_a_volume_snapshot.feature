@jira-MCF-37 @volumes
Feature: Create a Volume Snapshot
  As an authorized user, I want to create a snapshot of one of my volumes so
  that I can revert to it as needed.

  Background:
    * A project exists in the system
    * The project has 1 active instance
    * The project has 1 available volume


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a snapshot of the volume

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Project Manager | Can Create           |
