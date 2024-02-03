function Test-MicrosoftGraphConnection {
    # Tests the connection to Microsoft Graph and returns a boolean value
    try {
        $context = Get-MGContext
        if ($null -eq $context) {
            return $false
        }
        else {
            return $true
        }
    }
    catch {
        Format-Exception -Exception $PSItem
        return $false
    }
}