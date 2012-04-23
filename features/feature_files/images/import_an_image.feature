@future
Feature: Import an Image
  As a user, I want to import an image so that I can re-use the images that I
  created from other cloud providers.

  NOTE: If this feature is tagged with '@future' then that means it's for a future
  release. Please remove this note once the '@future' tag has been removed.


  Background:
    * A project exists in the system


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Import> an image to the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Import |
        | Project Manager | Can Import           |
        | Cloud Admin     | Can Import           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Import |
        | Developer       | Cannot Import        |
        | IT Security     | Cannot Import        |
        | Network Admin   | Cannot Import        |
        | (None)          | Cannot Import        |


  Scenario Outline: Import an Image
    Given I am authorized to import images to the project
     Then I can import an image with a format of <Image Format>

      Scenarios:
        NOTE: See the list of available image formats at http://goo.gl/0yGJg

        | Image Format |
        | Raw          |
        | AMI          |
        | VHD          |
        | VDI          |
        | qcow2        |
        | VMDK         |
        | OVF          |


  Scenario: Add Meta-data on Import
    NOTE: Users should be able to add arbitrary meta-data when they create an
    image. This meta-data should be in key-value pairs. For example:

      - description='This is a copy of our web server'
      - version='2.0'

    Users should be able to specify any key and value. Thus, the meta-data is
    like a set of custom fields.

    Given I am authorized to import images to the project
     Then I can add meta-data when I import an image
