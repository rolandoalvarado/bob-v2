@jira-MCF-41 @format-v2 @wip
Feature: Detach a Volume
  As a user, I want to detach a volume from my instance so that I can re-use
  the volume for other purposes or delete it altogether.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in a project <Can or Cannot Detach> any of its volumes

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Detach |
        | Member          | Can Detach           |
        | Project Manager | Can Detach           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Detach |
        | (None)          | Cannot Detach        |
