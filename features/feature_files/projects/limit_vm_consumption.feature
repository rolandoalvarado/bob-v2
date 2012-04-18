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
