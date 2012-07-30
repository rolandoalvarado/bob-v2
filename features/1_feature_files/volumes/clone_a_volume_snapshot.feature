@jira-MCF-124
Feature: Create a clone of a volume snapshot
  As an authorized user, I want to clone a volume on the storage node so that
  I can use it with one of my instances.

  Background:
    * A project exists in the system
    * The project has 1 available volume
    * The volume has 1 saved snapshot


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a clone of the volume snapshot

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Project Manager | Can Create           |
