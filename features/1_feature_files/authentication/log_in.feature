@jira-DPBLOG-7 @authentication
Feature: Log In
  As a registered user, I want to log in so that I can use mCloud

  Background:
    * A project exists in the system

  Scenario Outline:
    * If my username is rstark and my password is w1nt3rf3ll, I <Can or Cannot Log In> with the following credentials <Username>, <Password>

    @jira-DPBLOG-VC
    Scenarios: Valid credentials
      | Username  | Password   | Can or Cannot Log In |
      | rstark    | w1nt3rf3ll | Can Log In           |

    Scenarios: Invalid credentials
      | Username  | Password   | Can or Cannot Log In | Reason                                                       |
      | RSTARK    | w1nt3rf3ll | Cannot Log In        | Username is case sensitive (This is an OpenStack constraint) |
      | (None)    | w1nt3rf3ll | Cannot Log In        | Username can't be empty                                      |
      | rstark    | w0nt3rf3ll | Cannot Log In        | Invalid password                                             |


  Scenario Outline:
    * I will be redirected to the Log In page when I anonymously access <Secure Page>

    Scenarios:
      | Secure Page |
      | Projects    |
      | Users       |
      | Usage       |


  Scenario Outline:
    * Logging in after anonymously accessing <Secure Page> redirects me back to it

    Scenarios:
      | Secure Page |
      | Projects    |
      | Users       |
      | Usage       |
