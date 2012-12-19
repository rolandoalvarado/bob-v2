@smoke-test @jira-MCF-216 @format-v2
Feature: Smoke test
  Check mcloud basic functions.
  SSH connection with public ip ( Vm can ping to google )
  Instance snapshot
  Volume mount

  
  @jira-MCF-216-AFP
  Scenario: Assign a Floating IP
    * An instance is publicly accessible via its assigned floating IP

  @jira-MCF-216-CIS
  Scenario: Create a Instance Snapshot
    * A user with a role of Admin in a project Can Create an image from an instance

  @jira-MCF-216-AV
  Scenario: Attach a Volume
    * Volumes that are attached to an instance will be accessible from the instance