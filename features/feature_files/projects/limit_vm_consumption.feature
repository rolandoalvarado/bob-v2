@jira-DPBLOG-10
Feature: Limit a Project's VM Consumption
  A project owner needs to be able to limit the
  maximum number of VMs that his project may
  consume so that he can control the project's
  expenses.

  Non-functional requirement: The limit check needs
  to happen before the system even attempts to launch
  the VMs. Meaning, it should check what the total will
  be should it launch the new VMs. When the future total
  will be within the limit, then the launch proceeds.
  Otherwise, the system will return an error message.

  # Background:
  #   * A project named 'Marketing' exists in the cloud
  #   * Arya Stark is a member of that project
  #
  # Scenario Outline:
  #   Given the project's Maximum VM Usage is <Max>
  #     And there are <Existing> VMs in the project
  #    When Arya attempts to launch <Additional> VMs
  #    Then the UI will display '<Message>'
  #     And there will be <New> launching VMs in the system
  #
  #   Examples:
  #     | Max | Existing | Additional | Message                      | New |
  #     |  10 |    0     |     10     | Launching 10 VMs             |  10 |
  #     |   5 |    1     |      4     | Launching 4 VMs              |   4 |
  #     |  15 |    5     |     15     | Project is limited to 15 VMs |   0 |