@jira-DPBLOG-16 @jira-DPBLOG-17 @jira-MCF-42
Feature: Change a user's permissions

  @permissions
  Scenario Outline:
    * A user with a role of <Role> in the system <Can or Cannot Change> user permissions

      Scenarios: Authorized Roles
        | Role         | Can or Cannot Change |
        | System Admin | Can Change           |

      Scenarios: Unauthorized Roles
        | Role         | Can or Cannot Change |
        | (None)       | Cannot Change        |
