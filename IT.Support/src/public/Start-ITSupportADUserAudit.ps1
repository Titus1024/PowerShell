function Start-ITSupportADUserAudit {
    <#
    .DESCRIPTION
    Performs and audit of AD Users and can disable accounts that exceed the inactive threshold
    .PARAMETER InactiveThresholdInDays
    Sets the threshold for when an account is considered inactive
    Default value of 30
    .PARAMETER DisableAccounts
    Using this parameter will disable the AD Users that exceed the inactive threshold
    Cannot be used if the InactiveThresholdInDays value is less than 30 days
    .EXAMPLE
    Start-ITSupportADUserAudit
    Returns the AD Users that exceed 30 days of inactivity
    .EXAMPLE
    Start-ITSupportADUserAudit -InactiveThresholdInDays 30
    Returns the AD Users that exceed 30 days of inactivity
    NOTE: In this example, using DisableAccounts will cause the command to fail
    .EXAMPLE
    Start-ITSupportADUserAudit -DisableAccounts
    Disables the AD Users that exceed 30 days of inactivity
    .EXAMPLE
    Start-ITSupportADUserAudit -InactiveThresholdInDays 90 -DisableAccounts
    Disables the AD Users that exceed 90 days of inactivity
#>
    [CmdletBinding()]
    param (
        [int]
        $InactiveThresholdInDays,
        [switch]
        $DisableAccounts
    )

    try {
        if ($PSBoundParameters.Keys -contains 'DisableAccounts' -and $InactiveThresholdInDays -lt 30) {
            throw 'The InactiveThresholdInDays parameter does not accept values less than 30 when the DisableAccounts parameter is present'
        }
            
        $searchBase = $ITUtilities_Private.Config.UserOU
        $serviceAccountOUs = $ITUtilities_Private.Config.ServiceAccountOU
        $newlyCreatedAccounts = (Get-Date).AddDays(-30)
        $inactiveThreshold = (Get-Date).AddDays(-$InactiveThresholdInDays)
        $properties = @(
            "Name"
            "SamAccountName"
            "UserPrincipalName"
            "Enabled"
            "LockedOut"
            "LastLogonDate"
            "WhenCreated"
            "PasswordExpired"
            "PasswordNeverExpires"
            "AccountExpirationDate"
        )
        $inactiveUsers = Get-ADUser -SearchBase $searchBase -Properties $properties -Filter { Enabled -eq $true -and WhenCreated -lt $newlyCreatedAccounts -and LastLogonDate -lt $inactiveThreshold }
        
        $inactiveUsersFiltered = @()
        foreach ($inactiveUser in $inactiveUsers) {
            if ($inactiveUser.DistinguishedName -notmatch ($serviceAccountOUs -join '|')) {
                $inactiveUsersFiltered += $inactiveUser
            }
        }

        if ($PSBoundParameters.Keys -contains 'DisableAccounts') {
            foreach ($user in $inactiveUsersFiltered) {
                $user.SamAccountName | Block-ITSupportADUser -Reason ("Inactive account. Automatically disabled on {0}" -f (Get-Date -Format yyyy-MM-dd))
            }
        }
        else {
            return $inactiveUsersFiltered | Format-Table $properties
        }
    }
    catch {
        $PSItem | Format-Exception
    }
}