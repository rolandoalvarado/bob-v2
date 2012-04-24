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


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> a security group in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Member          | Can Edit           |
        | Cloud Admin     | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | (None)          | Cannot Edit        |


  Scenario Outline: Edit a Security Group
    Given I am authorized to edit a security group in the project
      And the project has a security group
     When I edit a security group with attributes <Name>, <Description>
     Then the security will be <Updated or Not>

      Scenarios: Valid Values
        | Name             | Description              | Updated or Not |
        | Database Servers | Only port 443 is allowed | Updated        |
        | Database Servers |                          | Updated        |

      Scenarios: Invalid Values
        | Name             | Description              | Updated or Not |
        |                  | Only port 443 is allowed | Not Updated    |


  Scenario Outline: Add a Rule During Edit
    Given I am authorized to edit a security group in the project
      And the project has 2 security groups named Web Servers, and Database Servers
     When I edit the Database Servers security group with the following rule: <Protocol>, <From Port>, <To Port>, <Source Type>, <Source>
     Then the security group will be <Updated or Not>

     Scenarios: Valid Rules
       | Protocol | From Port | To Port  | Source Type    | Source      | Updated or Not |
       | TCP      | (Random)  | (Random) | Subnet         | 0.0.0.0/25  | Updated        |
       | TCP      | (Random)  | (Random) | Security Group | Web Servers | Updated        |
       | UDP      | (Random)  | (Random) | Subnet         | 0.0.0.0/25  | Updated        |
       | UDP      | (Random)  | (Random) | Security Group | Web Servers | Updated        |
       | ICMP     | (Random)  | (Random) | Subnet         | 0.0.0.0/25  | Updated        |
       | ICMP     | (Random)  | (Random) | Security Group | Web Servers | Updated        |

     Scenarios: Invalid Rules
       | Protocol | From Port | To Port  | Source Type    | Source      | Updated or Not | Reason                                     |
       | (Any)    | (None)    | (Random) | Subnet         | 0.0.0.0/25  | Not Updated    | 'From Port' must be specified              |
       | (Any)    | (Random)  | (None)   | Subnet         | 0.0.0.0/25  | Not Updated    | 'To Port' must be specified                |
       | (Any)    | (Random)  | (None)   | Subnet         | 1.2.9.12    | Not Updated    | Source must be in CIDR notation            |
       | (Any)    | (Random)  | (Random) | Subnet         | (None)      | Not Updated    | 'Source' can't be empty                    |
       | (Any)    | (None)    | (Random) | Security Group | Web Servers | Not Updated    | 'From Port' must be specified              |
       | (Any)    | (Random)  | (None)   | Security Group | Web Servers | Not Updated    | 'To Port' must be specified                |
       | (Any)    | (Random)  | (Random) | Security Group | (None)      | Not Updated    | 'Source' can't be empty                    |
       | (Any)    | (Random)  | (Random) | Security Group | App Servers | Not Updated    | Security group 'App Servers' doesn't exist |
