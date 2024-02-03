function New-TeamsChat {
    # Starts a new chat between two or more users
    param(
        [string[]]$Users
    )
    try {
        if (!(Test-MicrosoftGraphConnection)) {
            $scopes = Get-MicrosoftGraphScopes
            Connect-MicrosoftGraph -Scopes $scopes.GraphScopeGroups.SendTeamsChatMessage
        }
            
        if ($users.Count -gt 2) {
            $chatType = 'group'
        }
        else {
            $chatType = 'oneOnOne'
        }
    
        $chatParams = @{
            chatType = $chatType
            members  = @()
        }
    
        foreach ($user in $users) {
            $userId = Get-MicrosoftGraphUser -Username $user -ErrorAction Stop
            $chatParams.members += @{
                "@odata.type"     = "#microsoft.graph.aadUserConversationMember"
                roles             = @(
                    "owner"
                )
                "user@odata.bind" = ("https://graph.microsoft.com/v1.0/users('{0}')" -f $userId.Id)
            }
        }
    
        $newChat = New-MgChat -BodyParameter $chatParams -ErrorAction Stop
        return $newChat
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}