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


  @permissions @nelvin
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> a volume in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Project Manager | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |


  Scenario Outline: Create a Volume Given Some Attributes
    Given I am authorized to create volumes in the project
     When I create a volume with attributes <Name>, <Size>
     Then the volume will be <Created or Not>

      Scenarios: Valid Values
        | Name             | Size   | Created or Not |
        | Database storage | 5GB    | Created        |

      Scenarios: Invalid Values
        | Name             | Size   | Created or Not | Reason              |
        | (None)           | 5GB    | Not Created    | Name can't be empty |
        | Database storage | (None) | Not Created    | Size can't be empty |
