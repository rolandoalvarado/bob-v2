@jira-DWC-16
Feature: View Instance Statistics
  As a user, I want to see the statistics for my instance, so that I will know
  if I need to do something about its capacity or configuration.

  How statistics can help a user:
  * Amanda is wondering why her web application is taking longer than usual to
    run certain operations. When she looks at the dashboard and clicks on
    the instance hosting that web application, she sees that it only has 4MB
    of free RAM. Based on this, she resizes the instances thereby increasing
    free RAM by 2GB.

  * George needs to diagnose and fix an unresponsive mail server. When he
    goes to the dashboard and clicks on the instance hosting the mail server,
    he sees that it's been generating a lot of error messages since last night.
    He then connects to the instance using SSH and then investigates the logs
    in detail to further understand how to fix the problem.

  Background:
    * A project exists in the system
    * The project has a running instance


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot View> instance statistics in that project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot View |
        | Member          | Can View           |
        | Admin           | Can View           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot View |
        | (None)          | Cannot View        |

  Scenario Outline: View Instance Statistics
    Given I am authorized to view instance statistics in the project
     Then I should see the <Type> statistics for the instance

      Scenarios:
        | Type |
        | RAM  |
        | CPU  |
        | Disk |
