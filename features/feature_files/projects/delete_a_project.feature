Feature: Delete a project
  As an authorized user, I want to delete a project so that I can free up
  unused resources.

  Background:
    * A project exists in the system
    * The project has one running instance


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Project Manager | Can Delete           |
        | Cloud Admin     | Can Delete           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Developer       | Cannot Delete        |
        | IT Security     | Cannot Delete        |
        | Network Admin   | Cannot Delete        |
        | Non-Member      | Cannot Delete        |


  Scenario: Delete a Project
    Given I am authorized to delete the project
     When I delete the project
     Then the project and all its resources will be deleted