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

  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a security group in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Project Manager | Can Create           |
        | Network Admin   | Can Create           |
        | Cloud Admin     | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | Developer       | Cannot Create        |
        | IT Security     | Cannot Create        |
        | (None)          | Cannot Create        |


  Scenario Outline: Create a Security Group
    Given I am authorized to create a security group in the project
      And the project has no security groups
     When I create a security group with attributes <Name>, <Description>
     Then the security group will be <Created or Not>

      Scenarios: Valid Values
        | Name             | Description              | Created or Not |
        | Database Servers | Only port 443 is allowed | Created        |
        | Database Servers |                          | Created        |

      Scenarios: Invalid Values
        | Name             | Description              | Created or Not | Reason              |
        |                  | Only port 443 is allowed | Not Created    | Name can't be empty |


  Scenario Outline: Add a Rule During Creation
    Given I am authorized to create a security group in the project
      And the project has only one security group named Web Servers
     When I create a security group with the following rule: <Protocol>, <From Port>, <To Port>, <Source Type>, <Source>
     Then the security group will be <Created or Not>

      Scenarios: Valid Rules
        | Protocol | From Port | To Port  | Source Type    | Source      | Created or Not |
        | TCP      | (Random)  | (Random) | Subnet         | 0.0.0.0/25  | Created        |
        | TCP      | (Random)  | (Random) | Security Group | Web Servers | Created        |
        | UDP      | (Random)  | (Random) | Subnet         | 0.0.0.0/25  | Created        |
        | UDP      | (Random)  | (Random) | Security Group | Web Servers | Created        |
        | ICMP     | (Random)  | (Random) | Subnet         | 0.0.0.0/25  | Created        |
        | ICMP     | (Random)  | (Random) | Security Group | Web Servers | Created        |

      Scenarios: Invalid Rules
        | Protocol | From Port | To Port  | Source Type    | Source      | Created or Not | Reason                                     |
        | (Any)    | (None)    | (Random) | Subnet         | 0.0.0.0/25  | Not Created    | 'From Port' must be specified              |
        | (Any)    | (Random)  | (None)   | Subnet         | 0.0.0.0/25  | Not Created    | 'To Port' must be specified                |
        | (Any)    | (Random)  | (None)   | Subnet         | 1.2.9.12    | Not Created    | Source must be in CIDR notation            |
        | (Any)    | (Random)  | (Random) | Subnet         | (None)      | Not Created    | 'Source' can't be empty                    |
        | (Any)    | (None)    | (Random) | Security Group | Web Servers | Not Created    | 'From Port' must be specified              |
        | (Any)    | (Random)  | (None)   | Security Group | Web Servers | Not Created    | 'To Port' must be specified                |
        | (Any)    | (Random)  | (Random) | Security Group | (None)      | Not Created    | 'Source' can't be empty                    |
        | (Any)    | (Random)  | (Random) | Security Group | App Servers | Not Created    | Security group 'App Servers' doesn't exist |