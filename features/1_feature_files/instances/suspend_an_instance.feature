@jira-MCF-21
Feature: Suspend an Instance
  As a user, I want to suspend an instance so that I can free up some RAM and
  vCPUs without permanently losing my instance's state.

  From the OpenStack docs (http://goo.gl/NtOfW):
  Suspending an instance frees up memory and vCPUS and can be compared to
  hibernating a machine. For more information on which hypervisors support
  suspension/resumption of an instance, see this page: http://goo.gl/3IRX3

  Background:
    * A project exists in the system
    * The project has 1 active instance


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Suspend> the instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Suspend |
        | Member          | Can Suspend           |
        | Project Manager | Can Suspend           |


  @test-delete-inst
  Scenario: Suspend an Instance
    Given I am authorized to suspend instances in the project
     Then I can suspend the instance
      And I cannot assign a floating IP to that instance
