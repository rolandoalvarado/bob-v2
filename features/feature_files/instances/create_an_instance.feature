@jira-DPBLOG-14 @jira-DPBLOG-18
Feature: Create an Instance
  As a user, I want to create instances in my projects so that I can
  deploy my applications (web apps, services, etc).

  The term "Instance" is synonymous with "Server Instance." An instance is
  created by launching a VM using a given machine image and machine flavor.

  Background:
    * A project exists in the system
    * The project has at least 1 image
    * The project has 0 instances


  @permissions @wip
  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot Create> an instance in the project

      Scenarios: Authorized Roles
        | Role            | Can or Cannot Create |
        | Member          | Can Create           |
      #   | Cloud Admin     | Can Create           |
      #
      # Scenarios: Unauthorized Roles
      #   | Role            | Can or Cannot Create |
      #   | (None)          | Cannot Create        |


  Scenario Outline: Create an Instance
    Given I am authorized to create instances in the project
     When I create an instance with attributes <Image>, <Name>, <Flavor>, <Keypair> and <Security Group>
     Then the instance will be <Created or Not>

      Scenarios: Valid Values
        | Image  | Name        | Flavor | Keypair | Security Group | Created or Not |
        | (Any)  | My Server   | (Any)  | (Any)   | (Any)          | Created        |

      Scenarios: Invalid Values
        | Image  | Name        | Flavor | Keypair | Security Group | Created or Not | Reason                                           |
        | (None) | My Server   | (Any)  | (Any)   | (Any)          | Not Created    | Must specify an image                            |
        | (Any)  | (None)      | (Any)  | (Any)   | (Any)          | Not Created    | Must specify a name                              |
        | (Any)  | My Server   | (Any)  | (None)  | (Any)          | Not Created    | Must supply a keypair                            |
        | (Any)  | My Server   | (Any)  | (Any)   | (None)         | Not Created    | Instance should have at least one security group |

      Scenarios: Specific Images
        | Image                 | Name        | Flavor | Keypair | Security Group | Created or Not |
        | Windows2008-R2-server | My Server   | (Any)  | (Any)   | (Any)          | Created        |
        | CentOS 5.8            | My Server   | (Any)  | (Any)   | (Any)          | Created        |
        | Ubuntu 10.04 (lucid)  | My Server   | (Any)  | (Any)   | (Any)          | Created        |
