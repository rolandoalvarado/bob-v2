@jira-MCF-35 @format-v2 @wip
Feature: Attach a Volume
  As a user, I want to attach a volume to my instance so that the instance will
  have a scalable, persistent storage.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  A Note for KVM Hypervisors:
  If you are using KVM as your hypervisor, then the actual device name in the
  guest will be different than the one specified in the nova volume-attach
  command. You can specify a device name to the KVM hypervisor, but the actual
  means of attaching to the guest is over a virtual PCI bus. When the guest
  sees a new device on the PCI bus, it picks the next available name (which in
  most cases is /dev/vdc) and the disk shows up there on the guest.
  http://docs.openstack.org/trunk/openstack-compute/admin/content/managing-volumes.html


  @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in a project <Can or Cannot Attach> any of its volumes

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Attach |
        | Member          | Can Attach           |
        | Project Manager | Can Attach           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Attach |
        | (None)          | Cannot Attach        |


  Scenario: Attach a Volume
    * Volumes that are attached to an instance will be accessible from the instance
