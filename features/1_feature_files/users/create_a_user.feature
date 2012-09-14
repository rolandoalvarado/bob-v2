@jira-DPBLOG-17 @jira-MCF-7 @format-v2
Feature: Create a User

  @permissions @jira-MCF-7-CUP
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the system <Can or Cannot Create> a user

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | System Admin    | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | User            | Cannot Create        |

  @jira-MCF-7-cuwca
  Scenario Outline: Create a user with certain attributes
    * An authorized user <Can or Cannot Create> a user with attributes <Username>, <Email>, <Password>, <Primary Project>, and <Role>

      @jira-MCF-7-vua
      Scenarios: Valid User Attributes
        | Username | Email                | Password | Primary Project | Role            | Can or Cannot Create |
        | astark   | astark@morphlabs.com | fkd2350a | (Any)           | Project Manager | Can Create           |
      @jira-MCF-7-iua
      Scenarios: Invalid User Attributes
        | Username | Email                | Password | Primary Project | Role            | Can or Cannot Create | Remarks                                           |
        | (None)   | astar3@morphlabs.com | fkd2350a | (Any)           | Project Manager | Cannot Create        | Username can't be empty                           |
        | astark   | (None)               | fkd2350a | (Any)           | Project Manager | Cannot Create        | Email can't be empty                              |
        | astark   | astark.com           | fkd2350a | (Any)           | Project Manager | Cannot Create        | Email format is invalid                           |
        | astark   | astar4@morphlabs.com | fkd2350a | (None)          | Project Manager | Cannot Create        | User must have a primary project                  |
	
