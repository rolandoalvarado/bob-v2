@jira-MCF-28
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

  Background:
    * A project exists in the system
    * A user named Arya Stark exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Grant> project membership to Arya Stark

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Grant |
        | System Admin    | Can Grant           |
        | Project Admin   | Can Grant           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Grant |
        | Member          | Cannot Grant        |
        | (None)          | Cannot Grant        |


  Scenario Outline: Add a Member to A Project
    Given I am authorized to grant project memberships
      And Arya Stark is not a member of the project
     When I grant project membership to her
     Then she can view the project
