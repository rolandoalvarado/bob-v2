@jira-MCF-40
Feature: Delete a volume
  As an authorized user, I want to delete a volume on the storage node so that
  I can free up resources.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  @permissions
  Scenario Outline:
    * A user with a role of <Role> in a project <Can or Cannot Delete> any of its volumes

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Project Manager | Can Delete           |
        | Member          | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | (None)          | Cannot Delete        |


  Scenario:
    * Volumes that are attached to an instance cannot be deleted