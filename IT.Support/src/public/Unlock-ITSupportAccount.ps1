function Unlock-ITSupportAccount {
    <#
    .DESCRIPTION
    Used to unlock AD accounts
    .PARAMETER Identity
    Provide the SamAccountName of the user you wish to unlock
    .PARAMETER ADObject
    Accepts AD objects as a parameter and from the pipeline
    .EXAMPLE
    Unlock-ITSupportAccount -Identity 'jdoe'
    .EXAMPLE
    Get-ITSupportADUser -Identity 'jdoe','fdo' -DoNotFormat | Unlock-ITSupportAccount
    .EXAMPLE
    Get-ITSupportLockedAccount | Unlock-ITSupportAccount
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ParameterSetName="Default")]
        [string]
        $Identity,
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Pipeline",DontShow)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $ADObject
    )
    begin {

    }
    process {
        try {
            if ($PSBoundParameters.Keys -contains 'Identity') {
                $ADObject = Get-ITSupportADUser -Identity $Identity -DoNotFormat
            }
            foreach ($object in $ADObject) {
                Unlock-ADAccount -Identity $object -ErrorAction Stop
                "{0} has been unlocked" -f $object.Name | Trace-Output -Level Information
            }
        }
        catch {
            Format-Exception -Exception $PSItem
        }
    }
    end {

    }
}