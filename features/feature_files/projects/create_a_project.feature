@jira-DPBLOG-9
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

  Background:
    * A user named Arya Stark exists in the system

  Scenario Outline: Check User Permissions
    Given I am <Logged In or Not>
     Then I <Can or Cannot Create> a project

      Examples:
        | Logged In or Not | Can or Cannot Create |
        | Logged In        | Can Create           |
        | Not Logged In    | Cannot Create        |


  Scenario Outline: Create a Project
    Given I am authorized to create projects
     When I create a project with attributes <Name>, <Description>
     Then the project will be <Created or Not>

      Examples: Valid Values
        | Name               | Description     | Created or Not |
        | My Awesome Project | Another project | Created        |
        | My Awesome Project | (None)          | Created        |

      Examples: Invalid Values
        | Name               | Description     | Created or Not | Reason           |
        | (None)             | Another project | Not Created    | Name is required |


  Scenario: Create a project
   Given I am authorized to create projects
    When I create a project
    Then I can view that project
     But Arya Stark cannot view that project