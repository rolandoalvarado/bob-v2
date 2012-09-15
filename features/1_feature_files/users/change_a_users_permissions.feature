@jira-MCF-42 @users @no_ci
Feature: Change a user's permissions

  @permissions
  Scenario Outline:
    * A user with a role of <Role> in the system <Can or Cannot Change> user permissions

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Change |
        | System Admin    | Can Change           |
        | Project Manager | Can Change           |
        | Member          | Can Change           |

      Scenarios: Unauthorized Roles
        | Role         | Can or Cannot Change |
        | (None)       | Cannot Change        |
