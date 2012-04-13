@jira-DPBLOG-7
Feature: Log In
  As a registered user, I should be able to log in so that I can use mCloud

  Background:
    * The following user exists:
      | Username | Password   |
      | rstark   | w1nt3rf3ll |


  Scenario Outline: Someone tries to log in
    When a user logs in with the following credentials: <Username>, <Password>
    Then he will be redirected to the <Redirect To> page
     And the system will display '<Message>'

    Examples: Valid credentials
      | Username  | Password   | Redirect To | Message                       |
      | rstark    | w1nt3rf3ll | Projects    | Welcome back, Robb!           |
      | RSTARK    | w1nt3rf3ll | Projects    | Welcome back, Robb!           |

    Examples: Invalid credentials
      | Username  | Password   | Redirect To | Message                       |
      | rstark    | w00t!      | Login       | Invalid username or password  |
      | rstark    | W1NT3RF3LL | Login       | Invalid username or password  |
      |           | w1nt3rf3ll | Login       | Invalid username or password  |


  Scenario Outline: Someone tries to access a secure page without logging in
     When an unauthenticated user tries to access the <Secure Page> page
     Then he will be redirected to the Login page
      And the system will display 'Please log in before proceeding'

    Examples: Secure Pages
      | Secure Page |
      | Projects    |
      | Users       |
      | Usage       |