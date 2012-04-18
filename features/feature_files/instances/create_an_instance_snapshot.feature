Feature: Create an Instance Snapshot
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

  Default image should be OVF
