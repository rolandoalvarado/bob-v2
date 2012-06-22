@jira-MCF-30
Feature: View a Project
  As a user, I should be able to see the details of a project
  # Currently, if user does not have project role and he is the system admin,
  # he can see the project. so last test may fail.  
 
  Background:
    * A project exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
    Then I <Can or Cannot View> the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot View |
        | Member          | Can View           |
        | Project Manager | Can View           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot View |
        | (None)          | Cannot View        |
