@jira-DPBLOG-19
Feature: Connect to an Instance
  As a user, I want to be able to connect to an instance, so that I can
  install binaries to it and configure it according to my needs.

  Background:
    * A project exists in the system
    * The project does not have any running instances

  Scenario Outline:
    Given I am authorized to create instances in the project
     When I create an instance on that project based on the image <Image Name>
     Then I can connect to that instance via <Remote Client>

    Examples:
      | Image Name            | Remote Client |
      | Windows2008-R2-server | RDP           |
      | CentOS 5.8            | SSH           |
      | Ubuntu 10.04 (lucid)  | SSH           |