function Add-ITSupportOneDriveMember {
    <#
    .DESCRIPTION
    # Shares the users OneDrive with the requested user(s)
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
        [string[]]
        $Identity,
        [Parameter(Mandatory)]
        [string]
        $OneDriveOwner,
        [Parameter(Mandatory)]
        [string]
        $TicketNumber
    )

    try {

        $userSiteUrl = "https://itsupport-my.sharepoint.com/personal/{0}_ITcom" -f $OneDriveOwner
        foreach ($user in $Identity) {
            $userToAdd = Get-ITSupportADUser -Identity $user
            Set-SPOUser -Site $userSiteUrl -LoginName $userToAdd.UserPrincipalName -IsSiteCollectionAdmin:$true -ErrorAction Continue
        }
        "{0}'s OneDrive has been shared with {1}" -f $OneDriveOwner, ($Identity -join ', ') | Trace-Output -Level Information

        $subject = "Request : ##RE-$TicketNumber##"
        $body = "
            Hello,<br>
            <br>
            You have been given access to {0}'s OneDrive for 3 months.<br>
            To access their OneDrive, please use the below link<br>
            {1}
            " -f $OneDriveOwner, $userSiteUrl
        $cc = $Identity -join ', '
        Send-Email -Subject $subject -Body $body -Cc $cc
    }
    catch {
        $PSItem | Format-Exception
    }
}