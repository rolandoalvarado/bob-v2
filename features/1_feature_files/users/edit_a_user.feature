@jira-MCF-44 @users
Feature: Edit a User

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the system
     Then I <Can or Cannot Edit> a user

      Scenarios: Authorized Roles
        | Role         | Can or Cannot Edit |
        | System Admin | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role         | Can or Cannot Edit |
        | User         | Cannot Edit        |


  Scenario Outline: Edit a user with certain attributes
    Given I am authorized to edit users in the system
     Then I <Can or Cannot Update> a user with attributes <Username>, <Email>, <Password>, <Primary Project>, and <Is PM or Not>

     Scenarios: Valid User Attributes
       | Username | Email                | Password | Primary Project | Is PM or Not | Can or Cannot Update | Remarks                                           |
       | astark   | astark@morphlabs.com | fkd2350a | (Any)           | Yes          | Can Update           |                                                   |
       | astark   | astar2@morphlabs.com | ++afd]3b | (Any)           | No           | Can Update           |                                                   |

     Scenarios: Invalid User Attributes
       | Username | Email                | Password | Primary Project | Is PM or Not | Can or Cannot Update | Remarks                                           |
       | (None)   | astar3@morphlabs.com | fkd2350a | (Any)           | Yes          | Cannot Update        | Username can't be empty                           |
       | astark   | (None)               | fkd2350a | (Any)           | Yes          | Cannot Update        | Email can't be empty                              |
       | astark   | astark.com           | fkd2350a | (Any)           | Yes          | Cannot Update        | Email format is invalid                           |
       | astark   | astar4@morphlabs.com | fkd2350a | (None)          | No           | Cannot Update        | User must have a primary project                  |
