Feature: View an Instance's VNC Console
  From the OpenStack docs (http://goo.gl/EfMkE):
  The VNC Proxy is an OpenStack component that allows users of Nova to access
  their instances through a websocket enabled browser (like Google Chrome 4.0).

  A VNC Connection works like so:
    * User connects over an API and gets a URL like http://ip:port/?token=xyz

    * User pastes URL in browser

    * Browser connects to VNC Proxy though a websocket enabled client like noVNC

    * VNC Proxy authorizes users token, maps the token to a host and port of an
      instance's VNC server

    * VNC Proxy initiates connection to VNC server, and continues proxying until
      the session ends