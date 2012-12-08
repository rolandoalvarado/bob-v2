@jira-MCF-33 @security_groups
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
    * Ensure that a security group exist

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> a security group in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Can Delete           |
        | Project Manager | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | (None)          | Cannot Delete        |

  @jira-MCF-33-DSG
  Scenario: Delete a Security Group That's in Use
    Given I am authorized to delete security groups in the project
      And the security group is still in use by an instance
     Then I Cannot Delete the security group
