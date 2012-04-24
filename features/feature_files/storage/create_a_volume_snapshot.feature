Feature: Create a Volume Snapshot
  As an authorized user, I want to create a snapshot of one of my volumes so
  that I can revert to it as needed.

  Background:
    * A project exists in the system
    * The project has a running instance
    * The project has an available volume


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a snapshot of the volume

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Cloud Admin     | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |

