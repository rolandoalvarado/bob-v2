@jira-DPBLOG-7
Feature: Log In
  As a registered user, I should be able to log in so that I can use mCloud

  Background:
    * The following user exists:
      | Username | Password   |
      | rstark   | w1nt3rf3ll |
    * No user is logged in

  Scenario Outline: Someone tries to log in
    When a user logs in with the following credentials: <Username>, <Password>
    Then he will be redirected to the <Redirect To> page

    Examples: Valid credentials
      | Username  | Password   | Redirect To |
      | rstark    | w1nt3rf3ll | Projects    |

    Examples: Invalid credentials
      | Username  | Password   | Redirect To |
      | RSTARK    | w1nt3rf3ll | Login       |
      |           | w1nt3rf3ll | Login       |
      | rstark    | w0nt3rf3ll | Login       |


  Scenario Outline: Someone tries to access a secure page without logging in
     When an unauthenticated user tries to access the <Secure Page> page
     Then he will be redirected to the Login page

    Examples: Secure Pages
      | Secure Page |
      | Projects    |
      | Users       |
      | Usage       |