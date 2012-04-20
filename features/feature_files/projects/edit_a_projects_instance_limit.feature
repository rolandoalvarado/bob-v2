@jira-DPBLOG-10
Feature: Edit a Project's Instance Limit
  As a project manager, I want to set the instance limit (aka maximum
  number of instances) in my project, so that I can control my project's
  resource usage.

  User Experience Requirement:
  The limit check needs to happen before the system even attempts to launch
  the instance so that the user won't have to wait for a few minutes to find
  out that he's over the limit after all.

  Background:
    * A project exists in the system

  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the instance limit of the project

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


  Scenario Outline: Edit the Project's Instance Limit
    Given I am authorized to set instance limit of the project
      And the project has <Running Instances> instances
      And the project has an instance limit of <Old Limit>
     When I set the instance limit to <New Limit>
     Then the project's instance limit will be <Updated or Not>

      Scenarios: Valid New Limit
        | Running Instances | Old Limit | New Limit | Updated or Not |
        | 1                 | 2         | 1         | Updated        |
        | 1                 | 2         | 3         | Updated        |

      Scenarios: Invalid New Limit
        | Running Instances | Old Limit | New Limit | Updated or Not | Reason                                                        |
        | 2                 | 2         | 1         | Not Updated    | Limit can't be lower than current number of running instances |
        | 1                 | 1         | 0         | Not Updated    | Limit can't be zero                                           |
        | 1                 | 1         | ABCD      | Not Updated    | Limit must be numeric                                         |
        | 1                 | 1         | +1        | Not Updated    | Limit must be numeric                                         |
