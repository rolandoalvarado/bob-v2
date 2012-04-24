Feature: List Projects
  As a user, I want to see all the projects that I have access to.

  From the OpenStack docs (http://goo.gl/DND5I):
  Projects are isolated resource containers forming the principal
  organizational structure within OpenStack Compute. They consist of a
  distinct set of VLAN, volumes, instances, images, keys, and members.

  Background:
    * A project exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot See> it in the list of projects

      Scenarios: Authorized Roles
        | Role            | Can or Cannot See |
        | Member          | Can See           |
        | Cloud Admin     | Can See           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot See |
        | (None)          | Cannot See        |
