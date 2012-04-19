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


  Scenario: Attach a Volume
    Given I can SSH to the instance
     Then I can attach the volume to the instance
