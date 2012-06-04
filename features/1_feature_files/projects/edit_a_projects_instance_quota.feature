@jira-DPBLOG-10 @jira-MCF-27 @format_v2
Feature: Edit a Project's Instance Quota
  As a project manager, I want to set the instance quota (aka maximum
  number of instances) in my project, so that I can control my project's
  resource usage.

  User Experience Requirement:
  The quota check needs to happen before the system even attempts to launch
  the instance so that the user won't have to wait for a few minutes to find
  out that he's over the quota after all.

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
