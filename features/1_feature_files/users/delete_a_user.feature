@jira-MCF-43 @users
Feature: Delete a user
  As an authorized user, I want to delete a user.

  Background:
    * A user named astark exists in the system


  @permissions @jira-MCF-43-CUP
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the system
     Then I <Can or Cannot Delete> the user astark


      @jira-MCF-43-AR
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | System Admin    | Can Delete           |
        | Admin           | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Cannot Delete        |


  Scenario: Delete a User
    Given I am authorized to delete users
     When I delete the user astark
     Then user astark will be deleted
      And she will not be able to log in
