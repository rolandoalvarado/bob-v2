@jira-DPBLOG-7
Feature: Log In
  As a registered user, I want to log in so that I can use mCloud

  Background:
    * I have the following credentials:
      | Username | Password   |
      | rstark   | w1nt3rf3ll |
    * I am not logged in

  Scenario Outline: Log in
    When I log in with the following credentials: <Username>, <Password>
    Then I will be redirected to the <Redirect To> page

    Scenarios: Valid credentials
      | Username  | Password   | Redirect To |
      | rstark    | w1nt3rf3ll | Projects    |

    Scenarios: Invalid credentials
      | Username  | Password   | Redirect To | Reason                                                       |
      | RSTARK    | w1nt3rf3ll | Login       | Username is case sensitive (This is an OpenStack constraint) |
      |           | w1nt3rf3ll | Login       | Username can't be empty                                      |
      | rstark    | w0nt3rf3ll | Login       | Invalid password                                             |


  Scenario Outline: Access a secure page without logging in first
     When I try to access the <Secure Page> page
     Then I will be redirected to the Login page

    Scenarios: Secure Pages
      | Secure Page |
      | Projects    |
      | Users       |
      | Usage       |