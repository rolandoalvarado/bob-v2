@jira-MCF-9 @format-v2 @wip @blocked @instances
Feature: Connect to an Instance
  As a user, I want to be able to connect to an instance, so that I can
  install binaries to it and configure it according to my needs.

  Scenario Outline:
    * An instance created based on the image <Image Name> is accessible via <Remote Client>

    Scenarios:
      | Image Name                           | Remote Client |
      | 64Bit CentOS 5.8 (v1.0.0)            | SSH           |
      | 64Bit CentOS 6.2                     | SSH           |
      | 64Bit Ubuntu 10.04                   | SSH           |
      | 64Bit Ubuntu 12.04                   | SSH           |
      | 64Bit Windows 2008 R2 Enterprise SP1 | RDP           |
