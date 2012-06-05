@jira-DPBLOG-10 @jira-MCF-27 @format_v2
Feature: Edit a Project's Instance Quota
  As a project manager, I want to set the instance quota (aka maximum
  number of instances) in my project, so that I can control my project's
  resource usage.

  User Experience Requirement:
  The quota check needs to happen before the system even attempts to launch
  the instance so that the user won't have to wait for a few minutes to find
  out that he's over the quota after all.

  June 5th: new mcloud has only 3 quota values. Floating IPs, Volumes and Cores
  So I create scenario only for them. 

  @permissions @jira-MCF-27-CUP
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in a project <Can or Cannot Edit> the instance quota of the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Project Manager | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | Member          | Cannot Edit        |

  @jira-MCF-27-EPIQ
  Scenario Outline: Edit the Project's Instance Quota
    * Project <Updated or Not> the quota of the project with <Floating IPs> , <Volumes> and <Cores>

      Scenarios: Valid New Quota
        | Floating IPs | Volumes | Cores | Updated or Not | Result |
        | +1           | +1      | +1    | can be updated | Normal update |
        | -1           | +1      | +1    | can be updated | Floating IP is unlimited |
        | +1           | -1      | +1    | can be updated | Volumes can't be lower than current values|
        | +1           | +1      | -1    | can be updated | Cores can't be lower than values|

      Scenarios: Invalid New Quota
        | Floating IPs | Volumes | Cores | Updated or Not    | Result | 
        |  ABCD        | +0      | +0    | cannot be updated | Floating IP should be numeric|
        | +0           | ABCD    | +0    | cannot be updated | Volumes should be numeric|
        | +0           | +0      | ABCD  | cannot be updated | Cores should be numeric|

      Scenarios: Warned New Quota
        | Floating IPs | Volumes | Cores | Updated or Not    | Result |
        |  0           | +1      | +1    | is warned         | Floating IP should be red|
        | +1           | 0       | +1    | is warned         | Volumes should be red|
        | +1           | +1      |  0    | is warned         | Cores should be red |
