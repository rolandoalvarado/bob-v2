@jira-MCF-32
Feature: Create a Security Group
  As an authorized user, I want to create a security group so that I can
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
    * Ensure that the project has no security groups


  @permissions @jira-MCF-32-cup
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a security group in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Project Manager | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |

  @jira-MCF-32-csg
  Scenario Outline: Create a Security Group
    Given I am authorized to create a security group in the project
    Then the security group with attributes <Name>, <Description> will be <Created or Not Created>

      Scenarios: Valid Values
        | Name             | Description              | Created or Not Created  |
        | Database Servers | Only port 443 is allowed | Created                 |
        | Database Servers | (None)                   | Created                 |

      Scenarios: Invalid Values
        | Name             | Description              | Created or Not Created  | Reason              |
        | (None)           | Only port 443 is allowed | Not Created             | Name can't be empty |

  @jira-MCF-32-ardc
  Scenario Outline: Add a Rule
    Given I am authorized to create a security group in the project
      And the project has only one security group named Web Servers
     When I add the following rule: <Protocol>, <From Port>, <To Port>, <CIDR>
     Then the security group rules will be <Added or Not>

      Scenarios: Valid Rules
        | Protocol | From Port | To Port  | CIDR        | Added or Not |
        | TCP      | (Random)  | (Random) | 0.0.0.0/25  | Added        |
        | UDP      | (Random)  | (Random) | 0.0.0.0/25  | Added        |
        | ICMP     | (Random)  | (Random) | 0.0.0.0/25  | Added        |

      Scenarios: Invalid Rules
        | Protocol | From Port | To Port  | CIDR        | Added or Not | Reason                            |
        | (Any)    | (None)    | (Random) | 0.0.0.0/25  | Not Added    | 'From Port' must be specified     |
        | (Any)    | (Random)  | (None)   | 0.0.0.0/25  | Not Added    | 'To Port' must be specified       |
        | (Any)    | (Random)  | (None)   | 1.2.9.12    | Not Added    | CIDR must be in CIDR notation     |
        | (Any)    | (Random)  | (Random) | (None)      | Not Added    | 'CIDR' can't be empty             |
