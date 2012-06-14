@jira-MCF-25
Feature: Delete a project
  As an authorized user, I want to delete a project so that I can free up
  unused resources.
  Currently  Authorized Roles # test will fail. because we have not implemented
  project base role. But we will do it in future release.

  Background:
    * A project exists in the system

  @permissions
  Scenario Outline: Check User Permissions
    Given I am a <Project Manager or User>
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the project

      Scenarios: Authorized Roles
        | Role            | Project Manager or User | Can or Cannot Delete |
        | Member          | Project Manager         | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Project Manager or User | Can or Cannot Delete |
        | Member          | User                    | Cannot Delete        |


  Scenario: Delete a Project with resource
    Given I am authorized to delete the project
      And The project has 1 active instance
     Then I Can Delete the project

