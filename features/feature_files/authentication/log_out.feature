@jira-DPBLOG-7
Feature: Log Out

  Scenario: Log out
    Given I am logged in
     When I log out
     Then I will be redirected to the Login page