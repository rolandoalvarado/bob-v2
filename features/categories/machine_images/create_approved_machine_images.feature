Feature: Create Approved Machine Images
  A project owner needs to create approved
  machine images so that the project's developers only
  deploy their applications in the same environment (e.g. same
  OS, binaries, and system configuration)

  Background:
      * A 'GIS' project exists in the system
      * Catelyn is the owner of that project
      * The following developers are members of that project:
        | Brandon   |
        | Robb      |
        | Jeoffrey  |

  Scenario: Successfully create the image
    Given Catelyn has a running instance
      And she has configured it according to her needs

     When she creates a new image from that instance
      And she makes the image available to the following developers:
        | Brandon |
        | Robb    |

     Then the new image should have the following ACL:
        | Developer | Has Access? |
        | Brandon   | yes         |
        | Robb      | yes         |
        | Jeoffrey  | no          |