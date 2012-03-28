@DPBLOG-16 @DPBLOG-17
Feature: Create a User
  This feature allows a cloud administrator or a project
  owner to create a user in the system. Cloud administrators
  will be able to add the user to any project while a project
  owner can only add the user to projects that she owns.

 Background: 
      The following users exist:
      | Username  | Role                  |
      | Clarice   | Cloud Administrator   |
      | Paul      | Project Owner         |
      | Dave	  | Developer		  |

 Scenario Outline: Try to create a user
  Given <User> is logged in
  When he tries to create a user in his project
  Then the new user <Can or cannot> login
		
 #Examples: Happy path
  | User    | Can or cannot |
  | Clarice | Can           |
  | Paul    | Can           |

 #Examples: Sad path
  | User    | Can or cannot |
  | Dave    | Cannot        |


 Scenario Outline: Try to create a user with invalid values
  Given Clarice is logged in
  When she tries to create a user with <Name>, <Email>, <Password> and <Password confirmation>
  Then the system will display <Message>
  And the new user cannot login

 #Examples:
  |Name  |Email            |Password   |Password confirmation  |Message                            |
  |Mark  |Mark             |1234       | 1234                  |Email is invalid                   |
  |James |@x.com           |qwer       | qwer                  |Email is invalid                   |
  |Fonsy |Fonsy@fonsy.com  |1234       | qwer                  |Password does not match            |
  |1     |A1@a1.com        |1234       | 1234                  |Name must be at least 4 characters |
