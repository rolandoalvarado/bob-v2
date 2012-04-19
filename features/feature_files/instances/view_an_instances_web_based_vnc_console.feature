Feature: View an Instance's Web-based VNC Console
  As a user, I want to view my instance's web-based VNC console so that I can
  connect and manage it graphically without installing a VNC client in my
  workstation.

  VNC Definition (adapted from Wikipedia http://goo.gl/bEN0n):
  Virtual Network Computing (VNC) is a graphical desktop sharing app that
  transmits keyboard and mouse events from the client, to the server and
  relays the graphical screen changes from the server, to the client. All of
  this can be done regardless of where in the network the client and server are
  located as long as they can connect to each another. The term "VNC" actually
  refers to a proprietary app but has since been used as a generic term to refer
  to any of the app's variants.

  VNC apps are usually installed in the client before they can be used. However,
  there are some VNC clients which run directly on the browser negating the need
  to install it on the client. Example: http://kanaka.github.com/noVNC

  From the OpenStack docs (http://goo.gl/EfMkE):
  The VNC Proxy is an OpenStack component that allows users of Nova to access
  their instances through a websocket enabled browser (like Google Chrome 4.0).

  Background:
    * A project exists in the system
    * The project has one running instance


  Scenario Outline: Check User Permissions
    Given I have a role of <Role> in the project
     Then I <Can or Cannot View> the instance's web-based VNC console

      Examples: Authorized Roles
        | Role            | Can or Cannot View |
        | Project Manager | Can View           |
        | Developer       | Can View           |
        | Cloud Admin     | Can View           |

      Examples: Unauthorized Roles
        | Role            | Can or Cannot View |
        | IT Security     | Cannot View        |
        | Network Admin   | Cannot View        |
        | (None)          | Cannot View        |