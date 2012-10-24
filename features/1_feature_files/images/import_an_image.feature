Feature: Import an Image
  As a user, I want to import an image so that I can re-use the images that I
  created from other cloud providers.


  @images @permissions
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in a project <Can or Cannot Import> an image

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Import |
        | Project Manager | Can Import           |
        | System Admin    | Can Import           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Import |
        | Member          | Cannot Import        |
        | (None)          | Cannot Import        |


  @images
  Scenario Outline: Import an Image
    * An authorized user can import an image with a format of <Image Format>

      Scenarios:
        NOTE: See the list of available image formats at http://goo.gl/0yGJg

        | Image Format |
      # | Raw          |
      # | VHD          |
      # | VMDK         |
      # | VDI          |
      # | ISO          |
      # | qcow2        |
        | AKI          |
        | AMI          |
        | ARI          |


  @future @images
  Scenario: Add Meta-data on Import
    NOTE: Users should be able to add arbitrary meta-data when they create an
    image. This meta-data should be in key-value pairs. For example:

      - description='This is a copy of our web server'
      - version='2.0'

    Users should be able to specify any key and value. Thus, the meta-data is
    like a set of custom fields.

    * An authorized user can add meta-data when importing an image
