function Send-TeamsChatMessage {
    # Sens an HTML formatted teams chat message
    param(
        $Users,
        $Message
    )
    try {
        if (!(Test-MicrosoftGraphConnection)) {
            $scopes = Get-MicrosoftGraphScopes
            Connect-MicrosoftGraph -Scopes $scopes.GraphScopeGroups.SendTeamsChatMessage
        }
        
        $chatId = New-TeamsChat -Users $Users
        $bodyParameter = @{
            body = @{
                contentType = 'html'
                content = $Message
            }
        }

        $null = New-MgChatMessage -ChatId $chatId.Id -BodyParameter $bodyParameter
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}