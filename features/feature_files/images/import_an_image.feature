@future
Feature: Import an Image
  As a user, I want to import an image so that I can re-use the images that I
  created from other cloud providers.

  NOTE: If this feature is tagged with '@future' then that means it's for a future
  release. Please remove this note once the '@future' tag has been removed.


  Background:
    * A project exists in the system


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Import> an image to the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Import |
        | Project Manager | Can Import           |
        | Cloud Admin     | Can Import           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Import |
        | Developer       | Cannot Import        |
        | IT Security     | Cannot Import        |
        | Network Admin   | Cannot Import        |
        | Non-Member      | Cannot Import        |


  Scenario Outline: Import an Image
    Given I am authorized to import images to the project
     When I import an image that has a format of <Image Format>
     Then the image will be imported to the project

      Examples:
        See the list of available image formats at http://goo.gl/0yGJg
        | Image Format |
        | Raw          |
        | AMI          |
        | VHD          |
        | VDI          |
        | qcow2        |
        | VMDK         |
        | OVF          |



  Scenario: Add Meta-data on Import
    I should be able to add arbitrary meta-data when I create an image. This
    meta-data should be in key-value pairs. For example: description='This is
    a copy of our web server'; version='2.0'. I should be able to specify any
    key and value. Thus, the meta-data is like a set of custom fields.

    Given I am authorized to import images to the project
     When I import an image and add meta-data to it
     Then the imported image should contain that meta-data