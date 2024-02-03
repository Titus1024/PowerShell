#
# Module manifest for module 'ITSupport'
#
# Generated by: mpolselli
#
# Generated on: 5/2/2023
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'IT.Support'

    # Version number of this module.
    ModuleVersion     = '1.2311.45.31171217'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '4063bb12-5298-41c6-b515-d343b6941631'

    # Author of this module
    Author            = 'Mike Polselli'

    # Company or vendor of this module
    CompanyName       = 'IT'

    # Copyright statement for this module
    Copyright         = '(c) IT 2023. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Support module for the IT Support team'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # Export public functions here
    FunctionsToExport = @(
        'Add-ItSupportADGroupMember'
        'Add-ItSupportMailboxMember'
        'Add-ItSupportOneDriveUser'
        'Block-ItSupportADUser'
        'Get-ItSupportADGroupMember'
        'Get-ItSupportADUser'
        'Get-ItSupportBitLockerKey'
        'Get-ItSupportLockedAccount'
        'Convert-ItSupportMailbox'
        'Disable-ItSupportADUser'
        'Reset-ItSupportPassword'
        'Start-ItSupportADUserAudit'
        'Unlock-ItSupportAccount'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = ''

    # Variables to export from this module
    VariablesToExport = ''

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = ''

    # HelpInfo URI of this module
    HelpInfoURI       = 'https://dev.azure.com/It/_git/DevOps?path=/README.md&_a=preview'
}




