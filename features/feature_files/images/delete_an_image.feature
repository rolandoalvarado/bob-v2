Feature: Delete an Image
  As a user, I want to delete an image in my project so that I can keep my list
  of images manageable

  From the OpenStack docs (http://goo.gl/vwNln):
  An image is a file containing information about a virtual disk that completely
  replicates all information about a working computer at a point in time
  including operating system information and file system information.


  Background:
    * A project exists in the system
    * The project has an image


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Delete> the image in the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Delete |
        | Project Manager | Can Delete           |
        | Cloud Admin     | Can Delete           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Developer       | Cannot Delete        |
        | IT Security     | Cannot Delete        |
        | Network Admin   | Cannot Delete        |
        | (None)          | Cannot Delete        |


  Scenario: Delete an Image
    Given I am authorized to delete images in the project
     When I delete the image in the project
     Then I can no longer user that image