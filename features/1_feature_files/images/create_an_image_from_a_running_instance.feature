@jira-MCF-10 @format-v2 @images @pending
Feature: Create an Image from a Running Instance
  As an authorized user, I want to create an image from a runnning instance, so that
  I can easily create one or more exact copies.

  From the OpenStack docs (http://goo.gl/vwNln):
  An image is a file containing information about a virtual disk that completely
  replicates all information about a working computer at a point in time
  including operating system information and file system information.

  @jira-MCF-10-roles @permissions
  Scenario Outline:
    * A user with a role of <Role> in a project <Can or Cannot Create> an image from an instance

      @jira-MCF-10-AR
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | System Admin    | Can Create           |
        | Project Manager | Can Create           |
        | Member          | Can Create           |
  
      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |

  Scenario Outline:
    * Image that will be created from the instance will have the visibility of <Visibility> and should be visible to <Visible To>

      Scenarios:
        | Visibility | Visible To |
        | (Default)  | Project    |
        | Private    | Project    |
        | Public     | Everyone   |

  Scenario Outline:
    * Image that will be created will be written in the OVF format

  Scenario Outline:
    * Image that will be created will have a meta-data
