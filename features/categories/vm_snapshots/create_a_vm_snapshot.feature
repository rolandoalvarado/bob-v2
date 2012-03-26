@future?
Feature: Create a VM Snapshot
  A project owner needs to create approved
  machine images so that the project's developers only
  deploy their applications in the same environment (e.g. same
  OS, binaries, and system configuration)

  These snapshots have to be stored outside the CN because
  our CNs don't have storage capabilities.

  The snapshots have to have meta-data in the snapshot. Custom
  fields: name, description, etc.

  Does snapshotting have versioning support? Something for future releases.

  Background:
      * A 'GIS' project exists in the system
      * Catelyn is the owner of that project
      * The following developers are members of that project:
        | Brandon   |
        | Robb      |
        | Jeoffrey  |
      * Catelyn has a running VM

  Scenario: Create a new image
     When she creates a new image from that VM
      And she makes the image available to the following developers:
        | Brandon |
        | Robb    |

     Then the new image should have the following ACL:
        | Developer | Has Access? |
        | Brandon   | yes         |
        | Robb      | yes         |
        | Jeoffrey  | no          |