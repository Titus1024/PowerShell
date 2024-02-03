function Get-MicrosoftGraphScopes {
    # Returns the predefined scopes
    $json = Get-Content -Path "$PSScriptRoot\..\config\config.json"
    $scopes = $json | ConvertFrom-Json
    return $scopes
}