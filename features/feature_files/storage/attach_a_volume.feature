Feature: Attach a Volume
  As a user, I want to attach a volume to my instance so that the instance will
  have a scalable, persistent storage.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  Background:
    * A project exists in the system
    * The project has a running instance
    * The project has an available volume


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Attach> the volume to the instance

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Cloud Admin     | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |


  Scenario Outline: Attach a Volume Given A Mount Point
    NOTE: The Mount Point can have a value of /dev/vda, /dev/vdb, ... /dev/vdz

    Given I am authorized to attach volumes to the instance
     When I attach the volume to the instance with mount point <Mount Point>
     Then the volume will be <Attached or Not> to the instance

      Scenarios: Valid Attributes
        | Mount Point | Attached or Not |
        | (Any)       | Attached        |

      Scenarios: Invalid Attributes
        | Mount Point | Attached or Not | Reason                        |
        | (None)      | Not Attached    | Mount point must be indicated |
