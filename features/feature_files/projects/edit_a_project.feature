Feature: Edit a Project
  As an authorized user, I want to edit a procet's details

  Background:
    * A project exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Project Manager | Can Edit           |
        | Cloud Admin     | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | Developer       | Cannot Edit        |
        | IT Security     | Cannot Edit        |
        | Network Admin   | Cannot Edit        |
        | (None)          | Cannot Edit        |


  Scenario Outline: Edit a Project
    Given I am authorized to edit the project
     When I edit the project's attributes to <Name>, <Description>
     Then the project will be <Updated or Not>

      Scenarios: Valid Values
        | Name               | Description     | Updated or Not |
        | My Awesome Project | Another project | Updated        |
        | My Awesome Project | (None)          | Updated        |

      Scenarios: Invalid Values
        | Name               | Description     | Updated or Not | Reason           |
        | (None)             | Another project | Not Updated    | Name is required |