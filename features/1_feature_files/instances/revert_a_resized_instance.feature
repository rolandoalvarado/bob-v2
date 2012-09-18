@jira-MCF-20 @revert
Feature: Revert a Resized Instance
  From the OpenStack docs (http://goo.gl/aqhti)

  @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in the project <Can or Cannot Revert> a resized instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Revert |
        | Member          | Can Revert           |
        | Project Manager | Can Revert           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Revert |
        | (None)          | Cannot Revert        |

  Scenario: Revert a Resized Instance
    * An instance that has been resized by an authorized user can be reverted to its original flavor
