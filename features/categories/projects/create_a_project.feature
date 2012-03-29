@jira-DPBLOG-9
Feature: Create a Project
  Cloud administrators should be able to create
  a project in the cloud so that they can group
  together users and VMs. Also, so that unrelated
  VMs are isolated from one another.

  # Background:
  #   * Robert Baratheon has a role of Cloud Administrator in the DCU
  #   * Arya Stark has a role of Developer in the DCU
  #
  # Scenario: Robert tries to create a project
  #   When Robert tries to create a project named 'Project Winterfell'
  #   Then the project will be created in the DCU
  #    And the system will display 'Project Winterfell was successfully created'
  #
  # Scenario: Arya tries to create a project
  #   When Arya tries to create a project
  #   Then the project will not be created in the DCU
  #    And the system will display 'You are not allowed to create projects'
  #    And the system will email a security alert to Robert