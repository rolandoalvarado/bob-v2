Feature: Resize an Instance
  As a user, I want to resize an instance so that I can adjust its capacity
  according to its resource demands.

  From the OpenStack docs (http://goo.gl/lgZWn):
  The resize operation converts an existing server to a different flavor, in
  essence, scaling the server up or down. The original server is saved for a
  period of time to allow rollback if there is a problem. All resizes should be
  tested and explicitly confirmed, at which time the original server is removed.
  All resizes are automatically confirmed after 24 hours if they are not
  explicitly confirmed or reverted.

  Background:
    * A project exists in the system
    * The project has a running instance
    * The project has more than one instance flavor


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Resize> the instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Resize |
        | Project Manager | Can Resize           |
        | Cloud Admin     | Can Resize           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Resize |
        | Developer       | Cannot Resize        |
        | IT Security     | Cannot Resize        |
        | Network Admin   | Cannot Resize        |
        | (None)          | Cannot Resize        |


  Scenario: Resize an Instance
    Given I am authorized to resize instances in the project
     When I resize the instance to a different flavor
     Then the instance should be resized