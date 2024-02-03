function Get-ITSupportLockedAccount {
    <#
    .DESCRIPTION
    Displays and returns any locked AD account as an AD object
    .EXAMPLE
    Get-ITSupportLockedAccount
    #>

    try {
        $lockedAccounts = Get-ADFilter -Filter LockedOut
        return $lockedAccounts
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}