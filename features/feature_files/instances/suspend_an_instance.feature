Feature: Suspend an Instance
  As a user, I want to suspend an instance so that I can free up some RAM and
  vCPUs without permanently losing my instance's state.

  From the OpenStack docs (http://goo.gl/NtOfW):
  Suspending an instance frees up memory and vCPUS and can be compared to
  hibernating a machine. For more information on which hypervisors support
  suspension/resumption of an instance, see this page: http://goo.gl/3IRX3

  Background:
    * A project exists in the system
    * The project has an instance that is running on KVM


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Suspend> the instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Suspend |
        | Project Manager | Can Suspend           |
        | Cloud Admin     | Can Suspend           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Suspend |
        | Developer       | Cannot Suspend        |
        | IT Security     | Cannot Suspend        |
        | Network Admin   | Cannot Suspend        |
        | (None)          | Cannot Suspend        |


  Scenario: Suspend an Instance
    Given I am authorized to suspend instances in the project
     Then I can suspend the instance
      And I cannot connect to that instance via ssh