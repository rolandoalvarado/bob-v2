Feature: View a Project's Compute Usage Report
  As a user, I want to see the usage report of my project so that I can manage
  its resource usage more effectively.

  Background:
    * A project exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot View> the project's usage report

      Scenarios: Authorized Roles
        | Role            | Can or Cannot View |
        | Member          | Can View           |
        | Admin           | Can View           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot View |
        | (None)          | Cannot View        |


  Scenario: View Project's Usage Report
    Given I am authorized to view the project's usage report
      And the project has 2 instances that have been running for at least 2 days
     Then the project will have a total compute usage of at least 96 VM hours


  Scenario Outline: View Project's Usage Report in a Different Format
    Given I am authorized to view the project's usage report
     Then I can download the usage report in <Format> format

      Scenarios:
        | Format |
        | HTML   |
        | CSV    |
