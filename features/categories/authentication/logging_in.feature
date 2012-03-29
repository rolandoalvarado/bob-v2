@DPBLOG-7
Feature: Logging In
  Users need to be logged in before using the application so that not just
  anyone can use the resources in a DCU. Logging in also helps identify the
  user so that the system can limit her actions based on the permissions
  given to her.

  Background:
    * The following user exists:
      | Name       | Email          | Password   |
      | Robb Stark | robb@stark.com | w1nt3rf3ll |
    * Robb is not logged in


  Scenario Outline: User tries to log in
    When he logs in with the following credentials: <Email>, <Password>
    Then he will be redirected to the <Page Name> page
     And the system will display '<Message>'

    Examples:
      | Email          | Password   | Page Name | Message                   |
      | robb@stark.com | w1nt3rf3ll | projects  | Welcome back, Robb Stark! |
      | robb@stark.com | w00t!      | login     | Invalid email or password |
      | d00p           | w1nt3rf3ll | login     | Invalid email or password |


  # Scenario Outline: User attempts to access a secure page without logging in
  #    When he attempts to access the <Page Name> page
  #    Then he will be redirected to the log in page
  #     And the system will display 'Please log in before proceeding'
  #
  #   Examples:
  #     | Page Name |
  #     | projects  |
  #     | users     |
  #     | usage     |
