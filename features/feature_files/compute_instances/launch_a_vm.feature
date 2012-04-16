@jira-DPBLOG-14 @jira-DPBLOG-18
Feature: Launch a VM
  As a project member, I should be able to launch VMs in my project
  so that I can deploy applications.

  Background:
    * A project exists in the system
    * The project has one machine image available

  Scenario Outline: Check permissions
    When <Membership Type> tries to launch a VM based on any available image
    Then the system will <Launch or Not> the VM

    Examples:
      | Membership Type     | Launch or Not |
      | Project Owner       | Launch        |
      | Project Member      | Launch        |
      | Non-Member          | Not Launch    |