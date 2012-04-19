Feature: Create a Volume on the Storage Node
  As an authorized user, I want to create a volume on the storage node so that
  I can use it with one of my instances.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  Background:
    * A project exists in the system
    * A storage node is available for use


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a volume in the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Create |
        | Project Manager | Can Create           |
        | Cloud Admin     | Can Create           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | Developer       | Cannnot Create       |
        | IT Security     | Cannot Create        |
        | Network Admin   | Cannot Create        |
        | (None)          | Cannot Create        |
