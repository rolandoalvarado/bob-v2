@jira-MCF-25 @projects
Feature: Delete a project
  As an authorized user, I want to delete a project so that I can free up
  unused resources.
  Currently  Authorized Roles # test will fail. because we have not implemented
  project base role. But we will do it in future release.

  Background:
    * A project exists in the system
    * A project does not have collaborator
    * The project has 0 active instances


  @permissions @jira-MCF-25-CUP
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | System Admin    | Can Delete           |
        | Project Manager | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Cannot Delete        |

  Scenario: Delete a Project with resource
    Given I am authorized to delete the project
      And The project has 1 active instance
     Then the project cannot be deleted

