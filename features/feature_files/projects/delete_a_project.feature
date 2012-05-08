Feature: Delete a project
  As an authorized user, I want to delete a project so that I can free up
  unused resources.

  Background:
    * A project exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Admin           | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Cannot Delete        |
        | (None)          | Cannot Delete        |


  Scenario: Delete a Project
    Given I am authorized to delete the project
      And the project has a running instance
     When I delete the project
     Then the project and all its resources will be deleted
