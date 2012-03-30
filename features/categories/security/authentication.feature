@jira-DPBLOG-7
Feature: Authentication
  This feature ensures that only recognized users can use the system.

  Background:
    * The following user exists:
      | Name | Username | Password   |
      | Robb | rstark   | w1nt3rf3ll |
    * Robb is not logged in


  Scenario Outline: Robb tries to log in
    When he logs in with the following credentials: <Name>, <Password>
    Then he will be redirected to the <Page Name> page
     And the system will display '<Message>'

    Examples: Valid credentials
      | Username  | Password   | Page Name | Message             |
      | rstark    | w1nt3rf3ll | Projects  | Welcome back, Robb! |
      | RSTARK    | w1nt3rf3ll | Projects  | Welcome back, Robb! |
      | Rstark    | w1nt3rf3ll | Projects  | Welcome back, Robb! |

    Examples: Invalid credentials
      | Username  | Password   | Page Name | Message                       |
      | rstark    | w00t!      | Login     | Invalid username or password  |
      | rstark    | W1NT3RF3LL | Login     | Invalid username or password  |
      | rstark    |            | Login     | Invalid name or password      |
      |           | w1nt3rf3ll | Login     | Invalid name or password      |


  Scenario Outline: Robb tries to access a secure page without logging in
     When he tries to access the <Page Name> page
     Then he should be redirected to the Login page
      And the system should display 'You need to be logged in first'

    Examples:
      | Page Name |
      | Projects  |
      | Users     |
      | Usage     |
      | Support   |


  Scenario: Robb logs out
    Given he is logged in
     When he logs out
     Then he should see the Login page
      And the system should display 'You have been logged out.'