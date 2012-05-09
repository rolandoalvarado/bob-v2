@MCF-26
Feature: Edit a Project
  As an authorized user, I want to edit a project's details

  Ideally, a user who is not a system admin but is granted manager role in a
  project should have the ability to edit that project.

  Background:
    * A project exists in the system

  @permissions
  Scenario Outline: Check User Permissions
    Given I am a <System Admin or User>
      And I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the project

      Scenarios: Authorized Roles
        | Role            | System Admin or User | Can or Cannot Edit |
        | Project Manager | System Admin         | Can Edit           |
        | Member          | System Admin         | Can Edit           |
        | Project Manager | User                 | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | System Admin or User | Can or Cannot Edit |
        | Member          | User                 | Cannot Edit        |

  Scenario Outline: Edit a Project
    Given I am authorized to edit the project
     When I edit the project's attributes to <Name>, <Description>
     Then the project will be <Updated or Not>

      Scenarios: Valid Values
        | Name                 | Description        | Updated or Not |
        | MCF-26_EDIT_PROJECT  | Succucessed MCF-26 | Updated        |

      Scenarios: Invalid Values
        | Name                 | Description        | Updated or Not | Reason                  |
        | (None)               | Wrong For MCF-26   | Not Updated    | Name is required        |
        | MCF-26_WRONG_PROJECT | (None)             | Not Updated    | Description is required |
