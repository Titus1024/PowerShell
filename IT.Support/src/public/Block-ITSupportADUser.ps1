function Block-ITSupportADUser {
    <#
    .DESCRIPTION
    Blocks access to the ITdomain and disables the AD User account
    .PARAMETER Identity
    Username of the account to be disabled
    .EXAMPLE
    Block-ITSupportADUser -Identity jdoe
    .NOTES
    Any additional information
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = "Identity")]
        [string]
        $Identity,
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "Pipeline", DontShow)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $ADObject,
        [Parameter()]
        #[ValidateNotNullOrEmpty()]
        [ValidateLength(3,100)]
        [string]
        $Reason
    )

    try {
        if ($PSBoundParameters.Keys -contains 'Identity') {
            $userToDisable = Get-ITSupportADUser -Identity $Identity -DoNotFormat
        }
        else {
            $userToDisable = Get-ITSupportADUser -Identity $ADObject -DoNotFormat
        }
        Disable-ADAccount -Identity $userToDisable.SamAccountName -Confirm:$false -ErrorAction Stop
        "The account for {0} has been disabled" -f $userToDisable.Name | Trace-Output -Level Information

        if ($PSBoundParameters.Keys -contains 'Reason') {
            Set-ADUser -Identity $userToDisable.SamAccountName -Description $Reason
        }

        #TODO Move AD user to disabled user OU
    }
    catch {
        $PSItem | Format-Exception
    }
}