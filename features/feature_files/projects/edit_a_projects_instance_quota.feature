@jira-DPBLOG-10
Feature: Edit a Project's Instance Quota
  As a project manager, I want to set the instance quota (aka maximum
  number of instances) in my project, so that I can control my project's
  resource usage.

  User Experience Requirement:
  The quota check needs to happen before the system even attempts to launch
  the instance so that the user won't have to wait for a few minutes to find
  out that he's over the quota after all.

  Background:
    * A project exists in the system

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the instance quota of the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Admin           | Can Edit           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | Member          | Cannot Edit        |
        | (None)          | Cannot Edit        |


  Scenario Outline: Edit the Project's Instance Quota
    Given I am authorized to set instance quota of the project
      And the project has <Running Instances> instances
      And the project has an instance quota of <Old Quota>
     When I set the instance quota to <New Quota>
     Then the project's instance quota will be <Updated or Not>

      Scenarios: Valid New Quota
        | Running Instances | Old Quota | New Quota | Updated or Not |
        | 1                 | 2         | 1         | Updated        |
        | 1                 | 2         | 3         | Updated        |

      Scenarios: Invalid New Quota
        | Running Instances | Old Quota | New Quota | Updated or Not | Reason                                                        |
        | 2                 | 2         | 1         | Not Updated    | Quota can't be lower than current number of running instances |
        | 1                 | 1         | 0         | Not Updated    | Quota can't be zero                                           |
        | 1                 | 1         | ABCD      | Not Updated    | Quota must be numeric                                         |
        | 1                 | 1         | +1        | Not Updated    | Quota must be numeric                                         |
