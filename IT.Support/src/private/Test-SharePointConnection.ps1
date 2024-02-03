function Test-SharePointConnection {
<#
    .DESCRIPTION
    Internal function for testing the connection to SharePoint online
#>

    try {
        $connectionTest = Get-SPOTenant -ErrorAction Stop
        if ($null -ne $connectionTest) {
            return $true
        }
    }
    catch {
        return $false
    }
}