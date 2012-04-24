Feature: Resume an Instance
  As a user, I want to resume a suspended instance so that I can use it again
  after I'm done doing any maintenance work on it.

  From the OpenStack docs (http://goo.gl/NtOfW):
  Suspending an instance frees up memory and vCPUS and can be compared to
  hibernating a machine. For more information on which hypervisors support
  suspension/resumption of an instance, see this page: http://goo.gl/3IRX3

  Background:
    * A project exists in the system
    * The project has an instance that is running on KVM
    * The instance is suspended


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Resume> the instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Resume |
        | Member          | Can Resume           |
        | Cloud Admin     | Can Resume           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Resume |
        | (None)          | Cannot Resume        |


  Scenario: Resume an Instance
    Given I am authorized to resume instances in the project
     When I resume the instance in the project
     Then I can connect to that instance via ssh
