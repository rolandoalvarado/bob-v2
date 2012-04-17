Feature: Connect to a Windows Instance via RDP
  As a user, I want to be able to connect to a Windows instance via RDP, so
  that I can configure it according to my needs.

  Background:
    * A project exists in the system
    * The project does not have any running instances

  Scenario Outline:
    Given a user is authorized to create instances in the project
     When she creates a Windows <Edition> instance
     Then she should be able to connect to it via RDP

    Examples:
      | Edition |
      | 2003    |
      | 2008    |