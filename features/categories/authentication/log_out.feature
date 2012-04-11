@jira-DPBLOG-7
Feature: Log Out

  Scenario: An authenticated user logs out
    Given a user is logged in
     When he logs out
     Then he should see the Login page
      And the system should display 'You have been logged out.'