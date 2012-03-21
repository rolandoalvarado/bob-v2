Feature: Create Approved Machine Images
  An organization head needs to create approved
  machine images so that developers only deploy their
  applications in the same environment (e.g. same
  OS, same binaries, same system configuration) whether
  deploying to development, staging, or production.

  Background:
      * A 'GIS' project exists in the system
      * Catelyn is a manager of that project
      * The following developers are members of that project:
        | Brandon   |
        | Robb      |
        | Jeoffrey  |

  Scenario: Successfully create the image
    Given Catelyn has a running instance
      And she has configured according to her needs
     When she creates a new image from that instance
      And she makes the image available to the following developers:
        | Brandon |
        | Robb    |
     Then the new image should have the following ACL:
        | Developer | Has Access? |
        | Brandon   | yes         |
        | Robb      | yes         |
        | Jeoffrey  | no          |