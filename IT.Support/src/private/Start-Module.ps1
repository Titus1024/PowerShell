function Start-Module {
    <#
    .DESCRIPTION
    Internal function for preparing the module
#>

    try {
        Confirm-Modules
        
        if (!(Test-VPNConnection)) {
            "Unable to communicate with the {0} domain, please check network or VPN status. Continue?" -f $ITUtilities_Private.Config.Domain | Write-Host
            if (!(Get-UserInput)) {
                break
            }
        }

        $testDatabase = Test-DatabaseConnection
        if ($testDatabase) {
            $Script:ITUtilities_Private.LoggingDefaults.ConnectionConfig = $testDatabase
        }
        else {
            $Script:ITUtilities_Private.LoggingDefaults.LoggingMode = 'File'
            "Unable to communicate with logging database, logs will be stored in your working directory" | Trace-Output -Level Warning
        }

        "Connect to ExchangeOnline?" | Trace-Output -Level Information
        if (Get-UserInput) {
            Connect-Exchange
        }
    }
    catch {
        $PSItem | Format-Exception
    }
}