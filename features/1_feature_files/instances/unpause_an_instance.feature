@jira-MCF-22
Feature: Unpause a Paused Instance
  As a user, I want to unpause a paused instance so that I can use it again after
  I'm done doing any maintenance work on it.

  From the OpenStack docs (http://goo.gl/NtOfW):
  Pausing an instance freezes the instance but keeps it in memory (RAM). For
  more information on which hypervisors support pausing/unpausing an instance,
  see this page: http://goo.gl/3IRX3

  Background:
    * A project exists in the system
    * The project has 1 paused instance


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Unpause> the instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Unpause |
        | Member          | Can Unpause           |
        | Project Manager | Can Unpause           |


  Scenario: Unpause an Instance
    Given I am authorized to unpause instances in the project
     When I unpause the instance in the project
      And I assign a floating IP to the instance
     Then I can connect to that instance via SSH
