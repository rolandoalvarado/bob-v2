Feature: Pause an Instance
  As a user, I want to pause an instance so that I can do maintenance work on it

  From the OpenStack docs (http://goo.gl/NtOfW):
  Pausing an instance freezes the instance but keeps it in memory (RAM). For
  more information on which hypervisors support pausing/unpausing an instance,
  see this page: http://goo.gl/3IRX3

  Background:
    * A project exists in the system
    * The project has an instance that is running on KVM


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Pause> the instance

      Examples: Authorized Roles
        | Role            | Can or Cannot Pause |
        | Project Manager | Can Pause           |
        | Cloud Admin     | Can Pause           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Pause |
        | Developer       | Cannot Pause        |
        | IT Security     | Cannot Pause        |
        | Network Admin   | Cannot Pause        |
        | (None)          | Cannot Pause        |


  Scenario: Pause an Instance
    Given I am authorized to pause instances in the project
     Then I can pause the instance in the project
      And I cannot connect to that instance via ssh