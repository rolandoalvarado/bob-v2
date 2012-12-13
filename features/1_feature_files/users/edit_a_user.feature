@jira-MCF-44 @format-v2 @users
Feature: Edit a User

  @permissions @jira-MCF-44-roles
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the system <Can or Cannot Edit> a user

      @jira-MCF-44-ar
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Admin           | Can Edit           |

      @jira-MCF-44-ur
      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | Member          | Cannot Edit        |
        | Project Manager | Cannot Edit        |

  @jira-MCF-44-eawca
  Scenario Outline: Edit a user with certain attributes
     * An authorized user <Can or Cannot Edit> a user with attributes <Username>, <Email>, <Password>, <Primary Project>, and <Role>
      
      @jira-MCF-44-vua
      Scenarios: Valid User Attributes
        | Username        | Email                       | Password | Primary Project | Role            | Can or Cannot Edit |
        | astarkMember    | astarkMember@morphlabs.com  | fkd2350a | (Any)           | Member          | Can Edit           |
        | astarkPM        | astarkPM@morphlabs.com      | fkd2350a | (Any)           | Project Manager | Can Edit           |

      @jira-MCF-44-iua
      Scenarios: Invalid User Attributes
        | Username | Email                | Password | Primary Project | Role            | Can or Cannot Edit | Remarks                                           |
        | astark   | (None)               | fkd2350a | (None)          | Project Manager | Cannot Edit        | Email can't be empty                              |
        | astark   | astark.com           | fkd2350a | (Any)           | Project Manager | Cannot Edit        | Email format is invalid                           |
        | astark   | astar4@morphlabs.com | fkd2350a | (None)          | Member          | Cannot Edit        | User must have a primary project                  |
