function Get-ITSupportADGroupMember {
<#
    .DESCRIPTION
    Gets the members of the specified AD groups
    .PARAMETER Identity
    The name of the group to be queried
    .PARAMETER DoNotFormat
    Switch to return the AD object(s) intact
    .EXAMPLE
    Get-ITSupportADGroupMember -Identity 'Example Group'
    .EXAMPLE
    Get-ITSupportADGroupMember -Identity 'Example Group' -DoNotFormat
#>
    [CmdletBinding()]
    param (
        $Identity,
        $DoNotFormat
    )

    try {
        $groupMembers = Get-ADGroupMember -Identity $Identity
        if ($PSBoundParameters.Keys -contains 'DoNotFormat')  {
            return $groupMembers
        }
        $groupMembers | Format-Table Name, SamAccountName -AutoSize -Wrap
    }
    catch {
        $PSItem | Format-Exception
    }
}