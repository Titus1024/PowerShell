function Get-UserCredential {
    <#
    .DESCRIPTION
    Prompts the technician for their helpdesk administrator credentials
#>

    try {
        $credential = Get-Credential -Message 'Enter your HD Username and Password'
        return $credential
    }
    catch {
        $PSItem | Format-Exception
    }
}