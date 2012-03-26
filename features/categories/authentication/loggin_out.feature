Feature: Logging Out

  Background:
    * The following user is logged in:
      | email                | password      |
      | mmaglana@gmail.com   | as4943dladdsf |


  Scenario: User tries to log out
     When he tries to log out
     Then he should be logged out
      And he should see the log in page
      And the system should display 'Signed out successfully.'