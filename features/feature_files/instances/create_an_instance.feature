@jira-DPBLOG-14 @jira-DPBLOG-18
Feature: Create an Instance
  The term "Instance" is synonymous with "Server Instance." An instance is
  created by launching a VM using a given machine image and machine flavor.

  As a user, I should be able to create instances in my projects so that I can
  deploy my applications (web apps, services, etc).

  Background:
    * A project exists in the system
    * An image is available for use

  Scenario Outline: Check User Permissions
    Given a user with a role of <Role> exists in the project
     Then she <Can or Cannot Create> an instance in the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Create |
        | Project Manager | Can Create           |
        | Cloud Admin     | Can Create           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | IT Security     | Cannot Create        |
        | Network Admin   | Cannot Create        |
        | Non-Member      | Cannot Create        |