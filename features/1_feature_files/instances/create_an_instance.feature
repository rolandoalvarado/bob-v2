@jira-DPBLOG-14 @jira-DPBLOG-18 @jira-MCF-14
Feature: Create an Instance
  As a user, I want to create instances in my projects so that I can
  deploy my applications (web apps, services, etc).

  The term "Instance" is synonymous with "Server Instance." An instance is
  created by launching a VM using a given machine image and machine flavor.

  Current restrictions:
  We have not implemented falvor , keypair , security group selection system. 
  We have to review specific images

  Background:
    * A project exists in the system
    * At least 1 image should be available for use in the project
    * The project has 0 active instances


  @permissions
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> an instance in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
        | Project Manager | Can Create           |
        | System Admin    | Can Create           |

      Scenarios: Unauthorized Roles
        | Role            | Can or Cannot Create |
        | (None)          | Cannot Create        |

  Scenario Outline: Create an Instance
    Given I am authorized to create instances in the project
     When I create an instance with attributes <Image>, <Name>, <Flavor>, <Keypair> and <Security Group>
     Then the instance will be <Created or Not>

      Scenarios: Valid Values
        | Image  | Name        | Flavor | Keypair | Security Group | Created or Not |
        | (Any)  | My Server   | (Any)  | (Any)   | (Any)          | Created        |


      Scenarios: Invalid Values
        | Image  | Name        | Flavor | Keypair | Security Group | Created or Not | Reason                                           |
        | (Any)  | (None)      | (Any)  | (Any)   | (Any)          | Not Created    | Must specify a name                              |
        | (Any)  | My Server   | (Any)  | (None)  | (Any)          | Not Created    | Must supply a keypair                            |
        | (Any)  | My Server   | (Any)  | (Any)   | (None)         | Not Created    | Instance should have at least one security group |

      Scenarios: Specific Images
        | Image                          | Name        | Flavor | Keypair | Security Group | Created or Not |
        | Windows 2008 Enterprise Server | My Server   | (Any)  | (Any)   | (Any)          | Created        |
        | CentOS 5.8                     | My Server   | (Any)  | (Any)   | (Any)          | Created        |
        | Ubuntu 10.04 Lucid             | My Server   | (Any)  | (Any)   | (Any)          | Created        |
        | Ubuntu 12.04 Precise           | My Server   | (Any)  | (Any)   | (Any)          | Created        |
