@jira-MCF-42 @users
Feature: Change a user's permissions

  @permissions
  Scenario Outline:
    * A user with a role of <Role> in the system <Can or Cannot Change> user permissions

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Change |
        | Admin           | Can Change           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Change |
        | Project Manager | Cannot Change        |
        | Member          | Cannot Change        |
