Feature: Create a Security Group
  Check if multiple security groups that have different policies are
  additive. E.g. if secgroup1 has port 80 open and secgroup2 has just 443 open,
  then a VM that is part of those security groups will have 80 and 443 open.