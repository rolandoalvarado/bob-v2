@jira-MCF-10 @pending
Feature: Create an Image from a Running Instance
  As a user, I want to create an image from a running instance, so that I can
  easily create one or more exact copies of the instance.

  From the OpenStack docs (http://goo.gl/vwNln):
  An image is a file containing information about a virtual disk that completely
  replicates all information about a working computer at a point in time
  including operating system information and file system information.


  Background:
    * A project exists in the system
    * The project has 1 active instance

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> an image from an instance in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Admin           | Can Create           |
        | Member          | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |


  Scenario Outline: Define Image Visibility on Create
    Note: To prevent the inadvertent exposure of secure data, creating an image
    from a running instance is private by default, unless explicitly set by the
    user as public.

    Given I am authorized to create images from instances in the project
     When I create an image from the instance and give it a visibility of <Visibility>
     Then the image should be visible to <Visible To>

      Scenarios:
        | Visibility | Visible To |
        | (Default)  | Project    |
        | Private    | Project    |
        | Public     | Everyone   |


  Scenario: Save Image in OVF Format
    Given I am authorized to create images from instances in the project
     Then the images I create will be written in the OVF format


  Scenario: Add Meta-data on Create
    NOTE: Users should be able to add arbitrary meta-data when they create an
    image. This meta-data should be in key-value pairs. For example:

      - description='This is a copy of our web server'
      - version='2.0'

    Users should be able to specify any key and value. Thus, the meta-data is
    like a set of custom fields.

    Given I am authorized to create images from instances in the project
     Then I can add meta-data when I create an image
