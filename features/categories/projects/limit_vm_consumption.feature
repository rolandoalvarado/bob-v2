@DPBLOG-10
Feature: Limit a Project's VM Consumption
  A project owner needs to be able to limit the
  maximum number of VMs that his project may
  consume so that he can control the project's
  expenses.

  The limit check needs to happen before actual VM launch

  Background:
    * A project named 'Marketing' exists in the cloud
    * Robert Baratheon is a manager of that project
    * Arya Stark is an developer in that project

  Scenario Outline:
    Given Robert has set the project's Maximum VM Usage to <Limit>
      And there are <Starting> VMs in the project
     When Arya attempts to launch <New> VMs
     Then there will be <Total> launched VMs in the system
      And the UI will display '<Message>'

    Examples:
      | Limit | Starting | New  | Total | Message                      |
      |  10   |    0     |  10  |  10   | Launching 10 VMs             |
      |   5   |    0     |   4  |   4   | Launching 4 VMs              |
      |  15   |    5     |  15  |   5   | Project is limited to 15 VMs |