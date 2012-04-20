Feature: Edit a User
  As an authorized user, I want to edit users.

  Background:
    * A user exists in the system

  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Edit> the user

      Examples: Authorized Roles
        | Role            | Can or Cannot Edit |
        | Cloud Admin     | Can Edit           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Edit |
        | Project Manager | Cannot Edit        |
        | Developer       | Cannot Edit        |
        | IT Security     | Cannot Edit        |
        | Network Admin   | Cannot Edit        |
        | (None)          | Cannot Edit        |


  Scenario Outline: Edit a user with certain attributes
    Given I am authorized to edit users in the system
     When I edit the user with attributes <Username>, <Email>, <Password>, and <Password Confirmation>
     Then the user will be <Updated or Not>

      Examples: Valid User Attributes
        | Username | Email                | Password | Password Confirmation | Updated or Not |
        | astark   | astark@morphlabs.com | fkd2350a | fkd2350a              | Updated        |
        | astark   | astark@morphlabs.com | ++afd]3b | ++afd]3b              | Updated        |

      Examples: Invalid User Attributes
        | Username | Email                | Password | Password Confirmation | Updated or Not | Reason                                            |
        | (None)   | astark@morphlabs.com | fkd2350a | fkd2350a              | Not Updated    | Username can't be empty                           |
        | astark+  | astark@morphlabs.com | fkd2350a | fkd2350a              | Not Updated    | Username can only contain alphanumeric characters |
        | astark   | (None)               | fkd2350a | fkd2350a              | Not Updated    | Email can't be empty                              |
        | astark   | astark.com           | fkd2350a | fkd2350a              | Not Updated    | Email format is invalid                           |
        | astark   | astark@morphlabs.com | Abqwe23a | fkd2350a              | Not Updated    | Passwords don't match                             |
        | astark   | astark@morphlabs.com | (None)   | fkd2350a              | Not Updated    | Passwords don't match                             |
        | astark   | astark@morphlabs.com | (None)   | (None)                | Not Updated    | Passwords don't match                             |


  Scenario Outline: Add a Membership During Creation
    Given I am authorized to edit users in the system
      And there is at least one project in the system
      And the user is not a member of that project
     When I update the user with the following membership: <Project>, <Role>, and <Is Primary>
     Then the user will be <Updated or Not>

      Examples: Valid Membership Attributes
        | Project | Role   | Is Primary | Updated or Not |
        | (Any)   | (Any)  | Yes        | Updated        |

      Examples: Invalid Membership Attributes
        | Project | Role   | Is Primary | Updated or Not | Reason                                      |
        | (None)  | (Any)  | Yes        | Not Updated    | Project must be indicated                   |
        | (Any)   | (None) | Yes        | Not Updated    | Role must be indicated                      |
        | (Any)   | (Any)  | No         | Not Updated    | At least one membership must be the primary |


  Scenario: Add a User Without a Membership
    Given I am authorized to edit users in the system
     When I edit a user and remove all her memberships
     Then the user will not be able to login
      And the system will display 'You are not a member of any project'