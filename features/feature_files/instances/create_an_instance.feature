@jira-DPBLOG-14 @jira-DPBLOG-18
Feature: Create an Instance
  As a project member, I should be able to create instances in my project
  so that I can deploy my applications.

  Background:
    * A project exists in the system
    * The project has one machine image available

  Scenario Outline: Check permissions
    When <Type of Member> tries to create an instance based on any available image
    Then the system will <Create or Not> the instance

    Examples: Authorized Members
      | Type of Member      | Create or Not |
      | Project Owner       | Create        |
      | Project Member      | Create        |

    Examples: Unauthorized Members
      | Type of Member      | Create or Not |
      | Non-Member          | Not Create    |