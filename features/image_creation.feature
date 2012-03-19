Feature: Image Creation
  Sysadmins provide the infrastructure to a team
  of developers. They need to make sure all developers
  are creating their applications in the same environment
  (i.e. same OS, same software versions).

  Background:
      * An 'HR Department' project exists
      * I am logged in as a sysadmin of that project
      * There is an existing image in the list of approved images
      * The following developers exist in the project:
        | abustardo |
        | caedo     |
        | sbeast    |

  Scenario: Successfully create the image
    Given I have instantiated the image and configured it as needed
     When I create an image from the instance
      And I make the image available to the following developers:
        | abustardo |
        | caedo     |
     Then the new image should be added to the list
      And the image should have the following ACL:
        | Developer | Has Access? |
        | abustardo | yes         |
        | caedo     | yes         |
        | sbeast    | no          |