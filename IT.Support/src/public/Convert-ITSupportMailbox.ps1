function Convert-ITSupportMailbox {
    <#
    .DESCRIPTION
    Converts the selected mailbox to either a Shared or Regular mailbox
    By default, the mailbox is converted to a Shared mailbox
    .PARAMETER Identity
    The owner of the mailbox to be converted
    .PARAMETER Type
    Conversion type to be taken against the selected mailbox
    .EXAMPLE
    Convert-ITSupportMailbox -Identity 'jdoe'
    By default, the mailbox is converted to a shared mailbox
    .EXAMPLE
    Convert-ITSupportMailbox -Identity 'jdoe' -Type Regular
    .EXAMPLE
    Convert-ITSupportMailbox -Identity 'jdoe' -Type Shared
    .NOTES
    Any additional information
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Identity,
        [Parameter(Mandatory)]
        [ValidateSet('Regular','Shared')]
        $Type
    )

    try {
        $upn = Get-ITSupportADUser -Identity $Identity
        Set-Mailbox -Identity $upn.UserPrincipalName -Type $Type -ErrorAction Stop
        "{0}'s mailbox has been converted into a shared mailbox" -f $upn.Name | Trace-Output -Level Information
    }
    catch {
        $PSItem | Format-Exception
    }
}