@jira-MCF-42 @users
Feature: Change a user's permissions

  @permissions
  Scenario Outline:
    * A user with a role of <Role> in the system <Can or Cannot Change> user permissions

      @jira-MCF-42-AR
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Change |
        | System Admin    | Can Change           |
        | Admin           | Can Change           |

      Scenarios: Unauthorized Roles
        | Role         | Can or Cannot Change |
        | Member       | Cannot Change        |
