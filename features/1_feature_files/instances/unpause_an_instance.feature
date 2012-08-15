@jira-MCF-22 @instances @format-v2
Feature: Unpause a Paused Instance
  As a user, I want to unpause a paused instance so that I can use it again after
  I'm done doing any maintenance work on it.

  From the OpenStack docs (http://goo.gl/NtOfW):
  Pausing an instance freezes the instance but keeps it in memory (RAM). For
  more information on which hypervisors support pausing/unpausing an instance,
  see this page: http://goo.gl/3IRX3

  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the project <Can or Cannot Unpause> an instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Unpause |
        | Member          | Can Unpause           |
        | Project Manager | Can Unpause           |

  Scenario: Unpause an Instance
    * An authorized user can unpause an instance in the project
