@jira-MCF-40 @format-v2 @volumes
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
    * The volume has 0 saved snapshot
    * The project has 1 available volume

  @permissions
  Scenario Outline:
    Given I have a role of <Role> in the project
    Then I <Can or Cannot Delete> a volume

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | System Admin    | Can Delete           |
        | Project Manager | Can Delete           |

  Scenario:
    * Volumes that are attached to an instance cannot be deleted
