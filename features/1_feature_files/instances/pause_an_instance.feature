@jira-MCF-16
Feature: Pause an Instance
  As a user, I want to pause an instance so that I can do maintenance work on it

  From the OpenStack docs (http://goo.gl/NtOfW):
  Pausing an instance freezes the instance but keeps it in memory (RAM). For
  more information on which hypervisors support pausing/unpausing an instance,
  see this page: http://goo.gl/3IRX3

  Background:
    * A project exists in the system
    * The project has 1 active instance

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Pause> the instance in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Pause |
        | Member          | Can Pause           |
        | Project Manager | Can Pause           |
        | System Admin    | Can Pause           |

  @test-delete-inst
  Scenario: Pause an Instance
    Given I am authorized to pause instances in the project
     Then I can pause the instance in the project
      And I cannot assign a floating IP to that instance
