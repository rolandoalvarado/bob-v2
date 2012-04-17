Feature: View a Project
  As a user, I should be able to see the details of a project

  Background:
    * A project exists in the system

  Scenario Outline: Check User Permissions
    Given a user has a role of <Role> in the project
     Then she <Can or Cannot View> the project

      Examples: Authorized Roles
        | Role            | Can or Cannot View |
        | Project Manager | Can View           |
        | Developer       | Can View           |
        | Network Admin   | Can View           |
        | Cloud Admin     | Can View           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot View |
        | IT Security     | Cannot View        |
        | Non-Member      | Cannot View        |
