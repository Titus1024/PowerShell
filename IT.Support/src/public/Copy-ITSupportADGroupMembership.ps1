function Copy-ITSupportADGroupMembership {
    <#
    .DESCRIPTION
    Description here
    .PARAMETER paramOne
    paramOne description
    .EXAMPLE
    Example description
    .NOTES
    Any additional information
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Identity,
        [Parameter(Mandatory, ParameterSetName = "CopyFrom")]
        [string]
        $CopyFrom,
        [Parameter(Mandatory, ParameterSetName = "Pipeline", DontShow)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $CopyFromObject,
        [switch]
        $Overwrite,
        [switch]
        $CustomizeCopy
    )

    try {
        switch ($PSBoundParameters.Keys) {
            'CopyFrom' {
                $groupsToCopy = Get-ADPrincipalGroupMembership -Identity $Identity
            }
            'CopyFromObject' { 
                $groupsToCopy = Get-ADPrincipalGroupMembership -Identity $CopyFromObject
            }
            'OverWrite' {

            }
            'CustomizeCopy' {

            }
        }
    }
    catch {
        $PSItem | Format-Exception
    }
}