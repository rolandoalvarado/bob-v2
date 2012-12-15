@images @jira-MCF-11
Feature: Delete an Image
  As a user, I want to delete an image in my project so that I can keep my list
  of images manageable

  From the OpenStack docs (http://goo.gl/vwNln):
  An image is a file containing information about a virtual disk that completely
  replicates all information about a working computer at a point in time
  including operating system information and file system information.


  @permissions  @jira-MCF-11-CUP
  Scenario Outline: Check User Permissions
    * A user with a role of <Role> in a project <Can or Cannot Delete> an image

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Delete |
        | System Admin    | Can Delete           |
        | Project Manager | Can Delete           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Delete |
        | Member          | Cannot Delete        |
        | (None)          | Cannot Delete        |

  @jira-MCF-11-DAI
  Scenario: Delete an Image
    * An image deleted in the project can no longer be used by that project
