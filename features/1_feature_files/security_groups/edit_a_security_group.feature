@jira-MCF-34 @security_groups
Feature: Edit a Security Group
  As an authorized user, I want to edit a security group so that I can
  control the incoming network traffic for one or more instances.

  From the OpenStack docs (http://goo.gl/wRnRh):
  A security group specifies which incoming network traffic should be delivered
  to the VM instances in that group. All other incoming traffic not specified
  by the security group is discarded. Users can modify rules for a group at any
  time. The new rules are automatically enforced for all running instances and
  instances launched from then on.

  Security groups are additive:
  For example, if secgroup1 accepts port 80 traffic and and secgroup2 accepts
  port 443 traffic, then an instance who is a member of both groups will be
  able to accept traffic at ports 80 and 443.

  Background:
    * A project exists in the system
    * Ensure that a user exists in the project
    * Ensure that a security group named Web Servers exist

  @permissions @jira-MCF-34-cup
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> a security group in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Admin           | Can Edit           |
        | Project Manager | Can Edit           |
        | Member          | Can Edit           |
        
      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | (None)          | Cannot Edit        |

  @jira-MCF-34-esg
  Scenario Outline: Edit a Security Group
    Given I am authorized to edit a security group in the project
     When I edit a security group with the following rule: <Protocol>, <From Port>, <To Port>, <CIDR>
     Then the rule will be <Added or Not>

     Scenarios: Valid Rules
       | Protocol | From Port | To Port  | CIDR        | Added or Not   |
       | TCP      | (Random)  | (Random) | 0.0.0.0/25  | Added          |
       | UDP      | (Random)  | (Random) | 0.0.0.0/25  | Added          |
       | ICMP     | (Random)  | (Random) | 0.0.0.0/25  | Added          |
       | TCP      | (Random)  | (Random) | (None)      | Added          |

     Scenarios: Invalid Rules
       | Protocol | From Port | To Port  | CIDR        | Added or Not   | Reason                            |
       | (Any)    | (None)    | (Random) | 0.0.0.0/25  | Not Added      | 'From Port' must be specified     |
       | (Any)    | (Random)  | (None)   | 0.0.0.0/25  | Not Added      | 'To Port' must be specified       |
       | (Any)    | (Random)  | (None)   | 1.2.9.12    | Not Added      | CIDR must be in CIDR notation     |

