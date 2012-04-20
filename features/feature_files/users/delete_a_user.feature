Feature: Delete a user
  As an authorized user, I want to delete a user.

  Background:
    * A user named astark exists in the system


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the user astark

      Examples: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Cloud Admin     | Can Delete           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Project Manager | Cannot Delete        |
        | Developer       | Cannot Delete        |
        | IT Security     | Cannot Delete        |
        | Network Admin   | Cannot Delete        |
        | (None)          | Cannot Delete        |


  Scenario: Delete a User
    Given I am authorized to delete users
     When I delete the user astark
     Then astark will be deleted
      And she will not be able to log in