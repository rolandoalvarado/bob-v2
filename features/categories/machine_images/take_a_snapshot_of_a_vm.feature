@future?
Feature: Take a Snapshot of a VM
  Taking a snapshot of a VM produces a machine image that
  can be used to launch other VMs. The machine image produced
  is always attached to a single project.

  Non-functional requirements:

    - These images have to be stored outside the CN because
      our CNs don't have storage capabilities.

    - The images have to have meta-data in the snapshot.
      Custom fields: name, description, etc.

    - Does creating an image have versioning support? Something
      for future releases.

  # Background:
  #     * A project has one running VM
  #     * Catelyn is the owner of that project
  #     * The following developers are members of that project:
  #       | Brandon   |
  #       | Robb      |
  #       | Jeoffrey  |
  #
  # Scenario: Create a new image
  #    When she takes a snapshot of that VM
  #     And she makes the produced image available to the following developers:
  #       | Brandon |
  #       | Robb    |
  #    Then the new image should have the following ACL:
  #       | Developer | Has Access? |
  #       | Brandon   | yes         |
  #       | Robb      | yes         |
  #       | Jeoffrey  | no          |