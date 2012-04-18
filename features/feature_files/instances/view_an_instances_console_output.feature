Feature: View an Instance's Console Output
  As a user, I want to view the console output of an instance in my project
  so that I will know if there are any errors during boot-up time.

  See "Server Console Output" section at http://api.openstack.org/

  Background:
    * A project exists in the system
    * The project has one running instance


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot View> console output of the instance

      Examples: Authorized Roles
        | Role            | Can or Cannot View |
        | Project Manager | Can View           |
        | Cloud Admin     | Can View           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot View |
        | Developer       | Cannot View        |
        | IT Security     | Cannot View        |
        | Network Admin   | Cannot View        |
        | Non-Member      | Cannot View        |
