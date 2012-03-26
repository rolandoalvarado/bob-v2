Feature: Add a member to a project
  NOTE: The term 'project' refers to a grouping of users and VMs in a given DCU
  In the old mCloud this was referred to as an 'organization'

  This feature provides DCU administrators and project owners the ability to
  add users to a project. DCU administrators can add users to any project while
  project owners can only add users to their own project

  Background:
    * The following projects exist in the DCU:
      | PROJECT NAME   | OWNER    |
      | Billing System | Robert   |
      | FMS System     | Amanda   |
      | HRIS           | Amanda   |
      | CMS            | Joe      |

    * Albert is a developer of another project


  Scenario: Amanda adds Albert to one of her projects
    When she adds Albert to the HRIS project with an accompanying message:
    """
    Hi Albert. I need your help setting up one of the VMs in this project.
    There seems to be a problem with installing Apache and Ruby 1.9.x

    Amanda
    """

    Then Albert should receive the following email notification:
    """
    Dear Albert,

    Congratulations! You've been given access to the HRIS project
    at <DCU URL>. To view the project, please click on the link below

    <LINK TO PROJECT>

    Additional message from Amanda:
    -------------------------------
    Hi Albert. I need your help setting up one of the VMs in this project.
    There seems to be a problem with installing Apache and Ruby 1.9.x

    Amanda
    """

     And he should be able to log in and see the users and running VMs in HRIS project


  Scenario: Amanda adds Albert to a project she doesn't own
    When Amanda tries to add Albert to the Billing System project
    Then Albert should not be added to that project
     And the system will display 'You are not allowed to add users to projects you do not own'
