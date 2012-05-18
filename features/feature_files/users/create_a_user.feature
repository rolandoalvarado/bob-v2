@jira-DPBLOG-16 @jira-DPBLOG-17
Feature: Create a User
  As a system administrator, I want to create users.

  Background:
    * A project exists in the system
    * I have a role of Project Manager in the project

  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the system
     Then I <Can or Cannot Create> a user

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | System Admin    | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | User            | Cannot Create        |


  Scenario Outline: Create a user with certain attributes
    Given I am authorized to create users in the system
      And a user with username <Username> does not exist in the system
     When I create a user with attributes <Username>, <Email>, <Password>, and <Password Confirmation>
     Then the user will be <Created or Not>

      Scenarios: Valid User Attributes
        | Username | Email                | Password | Password Confirmation | Created or Not |
        | astark   | astark@morphlabs.com | fkd2350a | fkd2350a              | Created        |
        | astark   | astark@morphlabs.com | ++afd]3b | ++afd]3b              | Created        |

      Scenarios: Invalid User Attributes
        | Username | Email                | Password | Password Confirmation | Created or Not | Reason                                            |
        | (None)   | astark@morphlabs.com | fkd2350a | fkd2350a              | Not Created    | Username can't be empty                           |
        | astark+  | astark@morphlabs.com | fkd2350a | fkd2350a              | Not Created    | Username can only contain alphanumeric characters |
        | astark   | (None)               | fkd2350a | fkd2350a              | Not Created    | Email can't be empty                              |
        | astark   | astark.com           | fkd2350a | fkd2350a              | Not Created    | Email format is invalid                           |
        | astark   | astark@morphlabs.com | Abqwe23a | fkd2350a              | Not Created    | Passwords don't match                             |
        | astark   | astark@morphlabs.com | (None)   | fkd2350a              | Not Created    | Passwords don't match                             |
        | astark   | astark@morphlabs.com | (None)   | (None)                | Not Created    | Passwords don't match                             |


  Scenario Outline: Add a Membership During Creation
    Given I am authorized to create users in the system
      And there is at least one project in the system
     When I create a user with the following membership: <Project>, <Role>, and <Is Primary>
     Then the user will be <Created or Not>

      Scenarios: Valid Membership Attributes
        | Project | Role   | Is Primary | Created or Not |
        | (Any)   | (Any)  | Yes        | Created        |

      Scenarios: Invalid Membership Attributes
        | Project | Role   | Is Primary | Created or Not | Reason                                      |
        | (None)  | (Any)  | Yes        | Not Created    | Project must be indicated                   |
        | (Any)   | (None) | Yes        | Not Created    | Role must be indicated                      |
        | (Any)   | (Any)  | No         | Not Created    | At least one membership must be the primary |


  Scenario: Add a User Without a Membership
    Given I am authorized to create users in the system
     When I create a user without a membership
     Then the user will not be able to login
      And the system will display 'You are not a member of any project'
