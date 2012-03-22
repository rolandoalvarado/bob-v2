Feature: Create a User Account
  A project owners needs to manage user accounts
  so that these users can create and destroy VMs
  on their own.

  Background:
    * A project named 'HRIS Team' exists in the cloud
    * Amanda is the owner of that project

  Scenario: Create user account
    When she creates a user named Albert Martinez in the project
    Then Albert should receive an email notification regarding his new account
     And he should be able to log in and see the running VMs in the project
