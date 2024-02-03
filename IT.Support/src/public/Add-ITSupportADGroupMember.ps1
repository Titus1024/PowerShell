function Add-ITSupportADGroupMember {
<#
    .DESCRIPTION
    Adds user(s) to a selected AD group
    .PARAMETER Identity
    Adds the selected user(s) to the selected AD group
    .PARAMETER ADObject
    Accepts AD objects from the pipeline that will be added to the selected AD group
    .PARAMETER GroupName
    The group to add the selected user(s) to
    .EXAMPLE
    Add-ITSupportADGroupMember -Identity 'jdoe' -GroupName 'Example Group'
    .EXAMPLE
    Add-ITSupportADGroupMember -Identity 'jdoe','rdoe' -GroupName 'Example Group'
    .EXAMPLE
    Get-ITSupportADUser -Identity 'jdoe' | Add-ITSupportADGroupMember -GroupName 'Example Group'
    .EXAMPLE
    Get-ITSupportADUser -Filter NoLogon30Days | Add-ITSupportADGroupMember -GroupName 'Example Group'
    .EXAMPLE
    Get-ADUser -Filter "Title -eq 'DevOps Engineer'" -Properties Title | Add-ITSupportADGroupMember -GroupName 'Example Group'
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ParameterSetName="Default")]
        [string]
        $Identity,
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Pipeline",DontShow)]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $ADObject,
        [Parameter(Mandatory)]
        [string]
        $GroupName
    )

    try {
        if ($PSBoundParameters.Keys -contains 'Identity') {
            $ADObject = Get-ITSupportADUser -Identity $Identity
        }
        Add-ADGroupMember -Identity $GroupName -Members $ADObject -ErrorAction Stop
        "{0} has been added to {1}" -f ($ADObject.Name -Join ', '), $GroupName
    }
    catch {
        $PSItem | Format-Exception
    }
}