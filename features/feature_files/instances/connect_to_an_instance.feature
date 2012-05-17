@jira-MCF-9
Feature: Connect to an Instance
  As a user, I want to be able to connect to an instance, so that I can
  install binaries to it and configure it according to my needs.

  Background:
    * A project exists in the system
    * The project has 0 active instances

  Scenario Outline:
    Given I am authorized to create instances in the project
     When I create an instance on that project based on the image <Image Name>
      And I assign a floating IP to the instance
     Then I can connect to that instance via <Remote Client>

    Scenarios:
      | Image Name                     | Remote Client |
      | Windows 2008 Enterprise Server | RDP           |
      | CentOS 5.8                     | SSH           |
      | Ubuntu 10.04 Lucid             | SSH           |
      | Ubuntu 12.04 Precise           | SSH           |
