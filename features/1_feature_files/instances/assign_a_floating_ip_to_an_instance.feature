@jira-MCF-6 @floating
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

  @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the project <Can or Cannot Assign> a floating IP to an instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Assign |
        | Member          | Can Assign           |
        | Project Manager | Can Assign           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Assign |
        | (None)          | Cannot Assign        |

  Scenario: Assign Floating IP
    * An instance is publicly accessible via its assigned floating IP
