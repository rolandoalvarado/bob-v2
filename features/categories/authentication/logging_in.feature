@DPBLOG-7
Feature: Logging In
  This feature helps ensure that only authenticated users are able to use the application.

  Background:
    * The following user exists:
      | Name       | Email          | Password   |
      | Robb Stark | robb@stark.com | w1nt3rf3ll |

  Scenario Outline: User tries to log in
    When he logs in with the following credentials: <Email>, <Password>
    Then he will be redirected to the <Page Name> page
     And the system will display '<Message>'

    Examples:
      | Email          | Password   | Page Name | Message                   |
      | robb@stark.com | w1nt3rf3ll | projects  | Welcome back, Robb Stark! |
      | robb@stark.com | w00t!      | login     | Invalid email or password |
      | d00p           | w1nt3rf3ll | login     | Invalid email or password |
      | rstark         | w1nt3rf3ll | login     | Invalid email or password |
      | rstark         |            | login     | Invalid email or password |
      |                | w1nt3rf3ll | login     | Invalid email or password |


  Scenario Outline: User attempts to access a secure page without logging in
    When he attempts to access <Page> without logging in first
    Then he will be redirected to the log in page
     And the system will display 'Please log in before proceeding'

    Examples:
      | Page      |
      | projects  |
      | users     |
      | usage     |
