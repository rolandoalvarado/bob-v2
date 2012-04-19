Feature: Detach a Volume
  As a user, I want to detach a volume from my instance so that I can re-use
  the volume for other purposes or delete it altogether.

  A Note on Volumes:
  A 'volume' is a detachable block storage device. You can think of it as a
  USB hard drive. It can only be attached to one instance at a time, so it
  does not work like a SAN. If you wish to expose the same volume to multiple
  instances, you will have to use an NFS or SAMBA share from an existing
  instance.

  Background:
    * A project exists in the system
    * The project has a running instance
    * The instance has an attached volume


  Scenario: Detach a Volume
    Given I can SSH to the instance
     Then I can detach the volume from the instance
