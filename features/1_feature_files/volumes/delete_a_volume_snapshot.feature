@jira-MCF-39 @volumes @wip
Feature: Delete a Volume Snapshot
  As an authorized user, I want to delete a volume snapshot so that I can free
  up resources in my storage node.

  Background:
    * A project exists in the system
    * The project has 1 available volume
    * The volume has 1 saved snapshot


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> a snapshot of the volume

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Can Delete           |
        | Project Manager | Can Delete           |
