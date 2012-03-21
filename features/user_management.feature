Feature: User Management
  The head of an organization needs to manage user accounts
  for each member of her team so that they can create
  and destroy VMs on their own.

  Background:
    * A project named 'HRIS Team' exists in the DCU
    * Amanda is a manager of that project

  Scenario: Create user account
    When she creates a user named Albert Martinez in the project
    Then Albert should receive an email notification regarding his new account
     And he should be able to log in and see the running VMs in the project
