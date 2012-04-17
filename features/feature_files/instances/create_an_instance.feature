@jira-DPBLOG-14 @jira-DPBLOG-18
Feature: Create an Instance
  As a user, I should be able to create instances in my projects so that I can
  deploy my applications (web apps, services, etc).

  The term "Instance" is synonymous with "Server Instance." An instance is
  created by launching a VM using a given machine image and machine flavor.

  Background:
    * A project exists in the system
    * An image is available for use

  Scenario Outline: Check User Permissions
    Given a user has a role of <Role> in the project
     Then she <Can or Cannot Create> an instance in the project

      Examples: Authorized Roles
        | Role            | Can or Cannot Create |
        | Project Manager | Can Create           |
        | Cloud Admin     | Can Create           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | IT Security     | Cannot Create        |
        | Network Admin   | Cannot Create        |
        | Non-Member      | Cannot Create        |


  Scenario Outline: Create an Instance
    Given a user is authorized to create instances in the project
     When she creates an instance with attributes <Image>, <Server Name>, <Flavor>, <Keypair> and <Security Group>
     Then the instance will be <Created or Not>

      Examples: Valid Values
        | Image  | Server Name | Flavor | Keypair | Security Group | Created or Not |
        | (Any)  | My Server   | (Any)  | (Any)   | (Any)          | Created        |

      Examples: Invalid Values
        | Image  | Server Name | Flavor | Keypair | Security Group | Created or Not |
        | (None) | My Server   | (Any)  | (Any)   | (Any)          | Not Created    |
        | (Any)  | (None)      | (Any)  | (Any)   | (Any)          | Not Created    |
        | (Any)  | My Server   | (Any)  | (None)  | (Any)          | Not Created    |
        | (Any)  | My Server   | (Any)  | (Any)   | (None)         | Not Created    |