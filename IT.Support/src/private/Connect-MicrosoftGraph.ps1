function Connect-MicrosoftGraph {
    # Connects to Microsoft Graph 
    param (
        [string[]]$Scopes
    )
    try {
        
        Connect-MgGraph -Scopes $Scopes
        
        if (Test-MicrosoftGraphConnection) {
            return
        }
        else {
            Connect-MgGraph -Scopes $Scopes
            if (!(Test-MicrosoftGraphConnection)) {
                throw 'Unable to connect to Microsoft Graph'
            }
            return
        }
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}