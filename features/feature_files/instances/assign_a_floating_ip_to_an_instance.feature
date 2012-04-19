Feature: Assign a Floating IP to an Instance
  As a user, I want to assign a floating IP address to my instance, so that
  when my instance's fixed IP changes after a relaunch, I can still reach it
  through its assigned floating IP.

  From the OpenStack docs (http://goo.gl/KBb4B):
  Every virtual instance is automatically assigned a private IP address. You
  may optionally assign public IP addresses to instances. OpenStack uses the
  term "floating IP" to refer to an IP address (typically public) that can be
  dynamically added to a running virtual instance. OpenStack Compute uses
  Network Address Translation (NAT) to assign floating IPs to virtual instances.

  Background:
    * A project exists in the system
    * The project has one running instance
    * The project does not have any floating IPs

  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Assign> a floating IP to an instance in the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Assign |
        | Project Manager | Can Assign           |
        | Cloud Admin     | Can Assign           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Assign |
        | Developer       | Cannot Assign        |
        | IT Security     | Cannot Assign        |
        | Network Admin   | Cannot Assign        |
        | (None)          | Cannot Assign        |


  Scenario: Assign Floating IP
    Given I am authorized to assign floating IPs to instances in the project
     When I assign a floating IP to the instance
     Then the instance should be accessible from that floating IP