@jira-MCF-43 @format-v2 @users
Feature: Delete a user
  
  @permissions @jira-MCF-43-CUP
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the system <Can or Cannot Delete> a user
    
      @jira-MCF-43-AR
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Admin           | Can Delete           |

      @jira-MCF-43-UR
      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Project Manager | Cannot Delete        |
        | Member          | Cannot Delete        |

  @jira-MCF-43-DU
  Scenario: Delete a User
    * An authorized user can delete the user named astark and that user will not be able to login
