@jira-DPBLOG-7
Feature: Log In
  As a registered user, I want to log in so that I can use mCloud

  Background:
    * A user with username 'rstark' and a password 'w1nt3rf3ll' exists
    * I am not logged in

  Scenario Outline: Log in
    When I login with the following credentials: <Username>, <Password>
    Then I will be <Logged In or Not>

    Scenarios: Valid credentials
      | Username  | Password   | Logged In or Not |
      | rstark    | w1nt3rf3ll | Logged In        |

    Scenarios: Invalid credentials
      | Username  | Password   | Logged In or Not | Reason                                                       |
      | RSTARK    | w1nt3rf3ll | Not Logged In    | Username is case sensitive (This is an OpenStack constraint) |
      | (None)    | w1nt3rf3ll | Not Logged In    | Username can't be empty                                      |
      | rstark    | w0nt3rf3ll | Not Logged In    | Invalid password                                             |


  Scenario Outline: Access a secure section without logging in first
     When I try to access the <Secure Section> section
     Then I will be asked to log in first
     When I login with the following credentials: rstark, w1nt3rf3ll
     Then I will see the <Secure Section> section

    Scenarios:
      | Secure Section |
      | Projects       |
      | Users          |
      | Usage          |