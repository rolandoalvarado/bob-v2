@jira-MCF-17
Feature: Reboot an Instance
  As a user, I want to reboot an instance so that any new updates will be
  fully installed.

  From the OpenStack docs (http://goo.gl/1AWJe):
  This operation enables you to complete either a soft or hard reboot of a
  specified server. With a soft reboot, the operating system is signaled
  to restart, which allows for a graceful shutdown of all processes. A hard
  reboot is the equivalent of power cycling the server.

  Background:
    * A project exists in the system
    * The project has 1 active instance


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Reboot> an instance in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Reboot |
        | Member          | Can Reboot           |
        | Project Manager | Can Reboot           |


  Scenario: Soft Reboot
    Given I am authorized to reboot an instance in the project
     When I soft reboot the instance
     Then the instance will reboot


  Scenario: Hard Reboot
    Given I am authorized to reboot an instance in the project
     When I hard reboot the instance
     Then the instance will reboot
