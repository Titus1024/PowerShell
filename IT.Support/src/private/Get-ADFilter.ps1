function Get-ADFilter {
    # Definitions of AD filters, can be easily expanded
    param(
        [string]$Filter,
        [array]$Properties
    )

    $searchBase = $ITUtilities_Private.Config.UserOU
    switch ($Filter) {
        'ActiveUsers' {
            $filterToReturn = Get-ADUser -SearchBase $searchBase -Filter "Enabled -eq 'True'" -Properties $Properties | Where-Object {$PSItem.LastLogonDate -ge (Get-Date).AddDays(-30)}
            return $filterToReturn
        }
        'LockedOut' {
            $filterToReturn = Search-ADAccount -SearchBase $searchBase -LockedOut -UsersOnly
            return $filterToReturn
        }
        'PasswordExpired' {
            $filterToReturn = Search-ADAccount -SearchBase $searchBase -PasswordExpired -UsersOnly
            return $filterToReturn
        }
        'PasswordExpiring1Day' {
            [int]$passwordExpiration = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
            $filterToReturn = Get-ADUser -SearchBase $searchBase -Filter "Enabled -eq 'True' -and PasswordNeverExpires -eq 'False'" -Properties $Properties | Where-Object {
                $null -ne $PSItem.PasswordLastSet -and $PSItem.PasswordExpired -ne $true -and ($passwordExpiration - ((Get-Date) - ($PSItem.PasswordLastSet)).Days) -le 1 
            }
            return $filterToReturn
        }
        'PasswordExpiring3Days' {
            [int]$passwordExpiration = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
            $filterToReturn = Get-ADUser -SearchBase $searchBase -Filter "Enabled -eq 'True' -and PasswordNeverExpires -eq 'False'" -Properties $Properties | Where-Object {
                $null -ne $PSItem.PasswordLastSet -and $PSItem.PasswordExpired -ne $true -and ($passwordExpiration - ((Get-Date) - ($PSItem.PasswordLastSet)).Days) -le 3 
            }
            return $filterToReturn
        }
        'NoLogon30Days' {
            $filterToReturn = Search-ADAccount -SearchBase $searchBase -AccountInactive -TimeSpan (New-TimeSpan -Days 30) -UsersOnly | Where-Object {$PSItem.Enabled -eq $true}
            return $filterToReturn
        }
        'NoLogon45Days' {
            $filterToReturn = Search-ADAccount -SearchBase $searchBase -AccountInactive -TimeSpan (New-TimeSpan -Days 45) -UsersOnly | Where-Object {$PSItem.Enabled -eq $true}
            return $filterToReturn
        }
        'NoLogon60Days' {
            $filterToReturn = Search-ADAccount -SearchBase $searchBase -AccountInactive -TimeSpan (New-TimeSpan -Days 60) -UsersOnly | Where-Object {$PSItem.Enabled -eq $true}
            return $filterToReturn
        }
        'NoLogon90Days' {
            $filterToReturn = Search-ADAccount -SearchBase $searchBase -AccountInactive -TimeSpan (New-TimeSpan -Days 90) -UsersOnly | Where-Object {$PSItem.Enabled -eq $true}
            return $filterToReturn
        }
    }
}