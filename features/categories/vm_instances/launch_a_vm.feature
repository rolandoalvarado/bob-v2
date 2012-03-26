@DPBLOG-14 @DPBLOG-18
Feature: Launch a VM
  This feature allows an authorized project member
  to launch a VM in a project.

  hypervisor to support: KVM

  Background:
    * A project named 'Department Store Management System' exists
    * The project has 2 machine images available
    * Marjorie is a developer of that project
    * Marjorie is logged in

  Scenario: Launch a VM
    When she tries to launch a VM in the project
    Then the system will ask which machine image she wants to use
    When she chooses the first image
     And fills in a friendly name for the new VM
    Then the system will launch the VM
     And the VM will be available in the project within 5 minutes