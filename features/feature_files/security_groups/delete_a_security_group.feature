Feature: Delete a Security Group
  As an authorized user, I want to delete a security group

  From the OpenStack docs (http://goo.gl/wRnRh):
  A security group specifies which incoming network traffic should be delivered
  to the VM instances in that group. All other incoming traffic not specified
  by the security group is discarded. Users can modify rules for a group at any
  time. The new rules are automatically enforced for all running instances and
  instances launched from then on.

  Background:
    * A project exists in the system
    * The project has 2 security groups named default, and Web Servers
    * The project has an instance that is a member of the default security group


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the Web Servers security group in the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Project Manager | Can Delete           |
        | Network Admin   | Can Delete           |
        | Cloud Admin     | Can Delete           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Developer       | Cannot Delete        |
        | IT Security     | Cannot Delete        |
        | (None)          | Cannot Delete        |


  Scenario: Delete a Security Group That's in Use
    Given I am authorized to delete security groups in the project
      And the instance is a member the Web Servers security group
     Then I cannot delete the Web Servers security group
