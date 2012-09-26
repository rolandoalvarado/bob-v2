@jira-MCF-26 @projects
Feature: Edit a Project
  As an authorized user, I want to edit a project's details

  Ideally, a user who is not a system admin but is granted manager role in a
  project should have the ability to edit that project.
  #MCF-84 from WC 1.0.1 , project manager role does not depend on project.

  Background:
    * A project exists in the system

  @permissions @jira-MCF-26-CUP
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | System Admin    | Can Edit           |
        | Project Manager | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | Member          | Cannot Edit        |

  @jira-MCF-26-EAP
  Scenario Outline: Edit a Project
    Given I am authorized to edit the project
     When I <Can or Cannot Edit> the project's attributes to <Name>, <Description>

      Scenarios: Valid Values
        | Name                 | Description        | Can or Cannot Edit |
        | MCF-26_EDIT_PROJECT  | Succucessed MCF-26 | Can Edit           |

      Scenarios: Invalid Values
        | Name                 | Description        | Can or Cannot Edit| Reason            |
        | (None)               | Wrong For MCF-26   | Cannot Edit        | Name is required |
        | MCF-26_WRONG_PROJECT | (None)             | Cannot Edit        | Description is required |
