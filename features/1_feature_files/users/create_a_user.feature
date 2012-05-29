@jira-DPBLOG-16 @jira-DPBLOG-17 @jira-MCF-7
Feature: Create a User

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the system
     Then I <Can or Cannot Create> a user

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | System Admin    | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | User            | Cannot Create        |


  Scenario Outline: Create a user with certain attributes
    Given I am authorized to create users in the system
     Then I <Can or Cannot Create> a user with attributes <Username>, <Email>, <Password>, <Primary Project>, and <Is PM or Not>

      Scenarios: Valid User Attributes
        | Username | Email                | Password | Primary Project | Is PM or Not | Can or Cannot Create | Remarks                                           |
        | astark   | astark@morphlabs.com | fkd2350a | (Any)           | Yes          | Can Create           |                                                   |
        | astark   | astar2@morphlabs.com | ++afd]3b | (Any)           | No           | Can Create           |                                                   |

      Scenarios: Invalid User Attributes
        | Username | Email                | Password | Primary Project | Is PM or Not | Can or Cannot Create | Remarks                                           |
        | (None)   | astar3@morphlabs.com | fkd2350a | (Any)           | Yes          | Cannot Create        | Username can't be empty                           |
        | astark   | (None)               | fkd2350a | (Any)           | Yes          | Cannot Create        | Email can't be empty                              |
        | astark   | astark.com           | fkd2350a | (Any)           | Yes          | Cannot Create        | Email format is invalid                           |
        | astark   | astar4@morphlabs.com | fkd2350a | (None)          | No           | Cannot Create        | User must have a primary project                  |