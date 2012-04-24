Feature: Delete a volume
  As an authorized user, I want to delete a volume on the storage node so that
  I can free up resources.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  Background:
    * A project exists in the system
    * The project has a volume


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> a volume in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Can Delete           |
        | Cloud Admin     | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | (None)          | Cannot Delete        |


  Scenario: Delete an attached volume
    Given the project has a running instance
      And the volume is attached to the instance
     Then I cannot delete the volume
