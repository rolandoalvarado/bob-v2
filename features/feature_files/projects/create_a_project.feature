@jira-DPBLOG-9
Feature: Create a Project
  As a user, I want to create a project in mCloud so that I can group my
  resources together and control who has access to them.

  From the OpenStack docs (http://goo.gl/DND5I):
  Projects are isolated resource containers forming the principal organizational
  structure within the Compute Service. They consist of a separate VLAN,
  volumes, instances, images, keys, and users.

  Additional info for devs working against the OpenStack API:
  A user can specify which project he or she wishes to use by appending
  :project_id to his or her access key. If no project is specified in the
  API request, Compute attempts to use a project with the same id as the user.

  Background:
    * A user named Arya Stark exists in the system

  Scenario: Create a project
    When I create a project
    Then I can view that project
     But Arya Stark cannot view that project