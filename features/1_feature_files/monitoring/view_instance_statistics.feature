@jira-DWC-16 @jira-MCF-8 @format-v2
Feature: View Instance Statistics
  As a user, I want to see the statistics for my instance, so that I will know
  if I need to do something about its capacity or configuration.

  How statistics can help a user:

  Amanda is wondering why her web application is taking longer than usual to
  run certain operations. When she looks at the dashboard and clicks on
  the instance hosting that web application, she sees that it only has 4MB
  of free RAM. Based on this, she resizes the instances thereby increasing
  free RAM by 2GB.

  George needs to diagnose and fix an unresponsive mail server. When he
  goes to the dashboard and clicks on the instance hosting the mail server,
  he sees that it's been generating a lot of error messages since last night.
  He then connects to the instance using SSH and then investigates the logs
  in detail to further understand how to fix the problem.

  @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in a project <Can or Cannot View> the statistics of its instances

      Examples: Authorized Roles
        | Role            | Can or Cannot View |
        | Member          | Can View           |
        | Project Manager | Can View           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot View |
        | (None)          | Cannot View        |

  @wip
  Scenario Outline:
    * Statistics for <Resource Type> should be visible from the Monitoring page

      Scenarios:
        | Resource Type |
        | RAM           |
        | CPU           |
        | Disk          |
