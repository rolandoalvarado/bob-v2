@jira-MCF-18 @instances @resize
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

  @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the project <Can or Cannot Resize> an instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Resize |
        | Member          | Can Resize           |
        | Project Manager | Can Resize           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Resize |
        | (None)          | Cannot Resize        |

  Scenario: Resize an Instance
    * An instance resized by an authorized user will have a different flavor
