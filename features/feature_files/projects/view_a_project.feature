Feature: View a Project
  As a user, I should be able to see the details of a project

  Background:
    * A project exists in the system


  @permissions @take
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
    Then I <Can or Cannot View> the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot View |
        | Member          | Can View           |
        | Admin           | Can View           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot View |
        | (None)          | Cannot View        |
