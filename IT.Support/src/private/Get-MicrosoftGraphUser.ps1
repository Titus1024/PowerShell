function Get-MicrosoftGraphUser {
    # Queries Microsoft Graph and returns a user object
    param(
        $Username
    )
    try {
        if (!(Test-MicrosoftGraphConnection)) {
            $scopes = Get-MicrosoftGraphScopes
            Connect-MicrosoftGraph -Scopes $scopes.GraphScopes.DirectoryReadAll
        }
        
        $mgUser = Get-MGUser -Filter "startsWith(userPrincipalName,'$username')" -ErrorAction Stop
        return $mgUser
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}