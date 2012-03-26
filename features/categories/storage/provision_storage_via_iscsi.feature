Feature: Provision Storage via iSCSI
  This allows an authorized user to provision an iSCSI
  storage volume for use by a VM.

  Scenario: Request for a volume
    Given Macky is logged in
     When he requests for a storage volume
     Then the system will create the volume
      And the system will display the volume target id