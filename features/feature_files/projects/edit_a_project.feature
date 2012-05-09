@MCF-26
Feature: Edit a Project
  As an authorized user, I want to edit a procet's details
  # Currently, #3 test in Check User Permissions scenario is failed.
  # If user is owner and he is not system admin,
  # he can't edit the project.

  Background:
    * A project exists in the system

  @permissions
  Scenario Outline: Check User Permissions
    Given I am a <System Administrator or Not> in the system
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the project

      Scenarios: Authorized Roles
        | Role            | System Administrator or Not | Can or Cannot Edit |
        | Project Manager | System Administrator        | Can Edit           |
        | Member          | System Administrator        | Can Edit           |
        | Project Manager | Not System Administrator    | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | System Administrator or Not | Can or Cannot Edit |
        | Member          | Not System Administrator    | Cannot Edit        |

  Scenario Outline: Edit a Project
    Given A project exists in the system
    Given I am a System Administrator in the system
    Given I have a role of Project Manager in the project
     When I edit the project's attributes to <Name>, <Description>
     Then the project will be <Updated or Not>

      Scenarios: Valid Values
        | Name                | Description        | Updated or Not |
        | MCF-26_EDIT_PROJECT | Succucessed MCF-26 | Updated        |

      Scenarios: Invalid Values
        | Name                 | Description        | Updated or Not | Reason                  |
        | (None)               | Wrong For MCF-26   | Not Updated    | Name is required        |
        | MCF-26_WRONG_PROJECT | (None)             | Not Updated    | Description is required |
