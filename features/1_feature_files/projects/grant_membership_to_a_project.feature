@jira-MCF-28 @projects
Feature: Grant Membership to a Project
  As a project owner, I want to grant project membership to other users so
  that they can help me manage the resources in it.

  From the OpenStack docs (http://goo.gl/DND5I):
  Projects are isolated resource containers forming the principal organizational
  structure within the Compute Service. They consist of a separate VLAN,
  volumes, instances, images, keys, and users.

  Additional info for devs working against the OpenStack API:
  A user can specify which project he or she wishes to use by appending
  :project_id to his or her access key. If no project is specified in the
  API request, Compute attempts to use a project with the same id as the user.

  @permissions @jira-MCF-28-CUP
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the project <Can or Cannot Grant> project membership

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Grant |
        | Admin           | Can Grant           |
        | Project Manager | Can Grant           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Grant |
        | Member          | Cannot Grant        |

  Scenario: Add a Member to a Project
    * A user granted project membership can view the project
