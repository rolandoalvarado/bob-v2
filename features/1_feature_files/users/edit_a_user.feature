@jira-MCF-44 @users 
Feature: Edit a User

  @permissions @jira-MCF-44-roles
  Scenario Outline: Check User Permissions
    Given a <Role> is in the system
     Then I <Can or Cannot Edit> a user

      @jira-MCF-44-ar
      Scenarios: Authorized Roles
        | Role            | Can or Cannot Edit |
        | System Admin    | Can Edit           |
        | Admin           | Can Edit           |
        
      Scenarios: Unauthorized Roles
        | Role         | Can or Cannot Edit |
        | Member       | Cannot Edit        |
        
    
  Scenario Outline: Edit a user with certain attributes
    Given I am authorized to edit users in the system
     Then I <Can or Cannot Update> a user with attributes <Username>, <Email>, <Password>, <Primary Project>, <Is PM or Not> and <Is Admin or Not>

     @jira-MCF-44-vua       
     Scenarios: Valid User Attributes
       | Username   | Email                 | Password | Primary Project | Is PM or Not| Is Admin or Not | Can or Cannot Update | Remarks                                           |
       | astarkAD   | astark@morphlabs.com  | fkd2350a | (Any)           | No          | Yes             | Can Update           |                                                 |
       | astarkPM   | astar2@morphlabs.com  | ++afd]2b | (Any)           | Yes         | No              | Can Update           |                                                 |
       | astarkME   | astarme@morphlabs.com | ++afd]3b | (Any)           | No          | No              | Can Update           |                                                 |

     Scenarios: Invalid User Attributes
       | Username | Email                | Password | Primary Project | Is PM or Not | Is Admin or Not    | Can or Cannot Update | Remarks                                           |
       | (None)   | astar3@morphlabs.com | fkd2350a | (Any)           | Yes          | No                 | Cannot Update      | Username can't be empty                           |
       | astark   | (None)               | fkd2350a | (None)          | No           | Yes                | Cannot Update        | Email can't be empty                              |
       | astark   | astark.com           | fkd2350a | (Any)           | Yes          | No                 | Cannot Update        | Email format is invalid                           |
       | astark   | astar4@morphlabs.com | fkd2350a | (None)          | No           | No                 | Cannot Update        | User must have a primary project                  |
       | astarkAD | (None)               | fkd2350a | (None)          | No           | Yes                | Cannot Update        | User must have a primary project                  |
