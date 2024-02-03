function Test-ExchangeConnection {
<#
    .DESCRIPTION
    Internal function for validating connection to Exchange online
#>

    try {
        $testCommand = Get-MailboxPlan
        if ($null -eq $testCommand) {
            return $false
        }
        return $true
    }
    catch {
        $PSItem | Format-Exception
    }
}