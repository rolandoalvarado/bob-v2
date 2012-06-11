@jira-MCF-9 @format-v2
Feature: Connect to an Instance
  As a user, I want to be able to connect to an instance, so that I can
  install binaries to it and configure it according to my needs.

  Scenario Outline:
    * An instance created based on the image <Image Name> is accessible via <Remote Client>

    Scenarios:
      | Image Name                     | Remote Client |
      | windows 2008 Enterprise server | RDP           |
      | CentOS 5.8                     | SSH           |
      | Ubuntu 10.04 Lucid             | SSH           |
      | Ubuntu 12.04 Precise           | SSH           |
