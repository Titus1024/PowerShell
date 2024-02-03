function Connect-Exchange {
<#
    .DESCRIPTION
    Internal function for connecting to Exchange online
#>

    try {
        Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
        'Connected to Exchange Online' | Trace-Output -Level Information
    }
    catch {
        $PSItem | Format-Exception
    }
}