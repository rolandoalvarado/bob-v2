Feature: Create a Security Group
  As an authorized user, I want to create a security group so that I can
  control the incoming network traffic for one or more instances.

  From the OpenStack docs (http://goo.gl/wRnRh):
  A security group specifies which incoming network traffic should be delivered
  to the VM instances in that group. All other incoming traffic not specified
  by the security group is discarded. Users can modify rules for a group at any
  time. The new rules are automatically enforced for all running instances and
  instances launched from then on.

  Security groups are additive. For example, if secgroup1 accepts port 80
  traffic and and secgroup2 accepts port 443 traffic, then an instance who is a
  member of both groups will be able to accept traffic at ports 80 and 443.