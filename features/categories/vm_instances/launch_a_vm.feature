@DPBLOG-14 @DPBLOG-18
Feature: Launch a VM
  This feature allows an authorized project member
  to launch a VM in a project.

  Background:
    * A project named 'CMS' exists
    * The project has the following machine images available:
      | MACHINE IMAGE |
      | Web Server    |
      | Database      |
    * Marjorie is a developer of that project

  Scenario: Launch a VM
    When Marjorie tries to launch a VM with the following attributes:
      | MACHINE IMAGE | FRIENDLY NAME | TAGS             |
      | Database      | Production DB | marj, production |
    Then the system will launch the VM within 5 to 10 minutes
     And the VM will have the following attributes:
      | FRIENDLY NAME | TAGS             |
      | Production DB | marj, production |
     And Marjorie should be able to SSH to it