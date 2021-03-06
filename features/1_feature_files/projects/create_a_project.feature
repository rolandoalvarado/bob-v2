@jira-DPBLOG-9 @jira-MCF-4 @projects
Feature: Create a Project
  As a user, I want to create a project in mCloud so that I can group my
  resources together and control who has access to them.

  From the OpenStack docs (http://goo.gl/DND5I):
  Projects are isolated resource containers forming the principal
  organizational structure within OpenStack Compute. They consist of a
  distinct set of VLAN, volumes, instances, images, keys, and members.

  Additional info for devs working against the OpenStack API:
  A user can specify which project he or she wishes to use by appending
  :project_id to his or her access key. If no project is specified in the
  API request, Compute attempts to use a project with the same id as the user.


  @permissions @jira-MCF-4-CUP
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the system <Can or Cannot Create> a project

      @jira-MCF-4-AR
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Admin           | Can Create           |
        | Project Manager | Can Create           |


      @jira-MCF-4-UR
      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Cannot Create        |

  @jira-MCF-4-CAP
  Scenario Outline: Create a Project
    * An authorized user <Can or Cannot Create> a project with attributes <Name>, <Description>


      @jira-MCF-4-VA
      Scenarios: Valid Values
        | Name            | Description     | Can or Cannot Create |
        | MCF-4-CAP       | Another project | Can Create           |


      Scenarios: Invalid Values
        | Name            | Description     | Can or Cannot Create | Reason                  |
        | (None)          | Wrong name      | Cannot Create        | Name is required        |
        | Wrong Desc      | (None)          | Cannot Create        | Description is required |

  @jira-MCF-4-CPT
  Scenario: Create a Project That is Not Accessible to Another User
   Given I am authorized to create projects
     And a user named Arya Stark exists in the system
    When I create a project
    Then I can view that project
     But Arya Stark cannot view that project
