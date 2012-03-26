Feature: Create a volume for block storage
  This allows an authorized user to provision a
  storage volume for use by a VM.

  This is created on a per VM basis

  Scenario: Request for a volume
    Given Macky is logged in
     When he requests for a storage volume
     Then the system will create the volume
      And the system will display the volume target id