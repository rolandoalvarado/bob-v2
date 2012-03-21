Feature: Image Creation
  Sysadmins provide the infrastructure to a team
  of developers. They need to make sure all developers
  are creating their applications in the same environment
  (i.e. same OS, same software versions).

  Background:
      * A 'Human Resources' department exists in the system
      * I am logged in as an admin of that department
      * There is an existing image in the list of approved images
      * The following users exist in the department:
        | abustardo |
        | caedo     |
        | sbeast    |

  Scenario: Successfully create the image
    Given I have instantiated the image and configured it as needed
     When I create an image from the instance
      And I make the image available to the following users:
        | abustardo |
        | caedo     |
     Then the new image should be added to the list
      And the image should have the following ACL:
        | User      | Has Access? |
        | abustardo | yes         |
        | caedo     | yes         |
        | sbeast    | no          |