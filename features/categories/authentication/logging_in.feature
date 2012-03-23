Feature: Logging In
  This feature helps ensure that only authenticated users are able to use the application.

  Background:
    * The following user exists:
      | Username | Password |
      | admin    | klnm12   |


  Scenario Outline: User tries to log in
    When he logs in with the following credentials: <Email>, <Password>
    Then he will be redirected to the <Page Name> page
     And the system will display '<Message>'

    Examples:
      | Email | Password | Page Name | Message                   |
      | admin | klnm12   | projects  | Signed in successfully    |
      | admin | w00t!    | login     | Invalid email or password |
      | d00p  | klnm12   | login     | Invalid email or password |
      | admin |          | login     | Invalid email or password |
      |       | klnm12   | login     | Invalid email or password |


  Scenario Outline: User attempts to access a secure page without logging in
    When he attempts to access <Page> without logging in first
    Then he will be redirected to the log in page

    Examples:
      | Page      |
      | projects  |
      | users     |
      | usage     |


  Scenario: User tries to visit the login page when he's already logged in
    Given he is logged in
     When he visits the log in page
     Then he will be redirected to the projects page


  Scenario Outline: User logs in after being redirected
    This outline ensures that the user doesn't have to manually
    go back to the page he was trying to access before logging in.

    Given he successfully logged in after being redirected from <Page>
    Then he will be redirected to <Page>

    Examples:
      | Page      |
      | dashboard |
      | account   |