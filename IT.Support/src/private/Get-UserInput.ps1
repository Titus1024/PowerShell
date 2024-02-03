function Get-UserInput {
    # Provides a consistent experience when prompting the user for input
    Write-Host "Proceed with this action? [Y]es [N]o" -ForegroundColor Green
    Write-Host 'Enter your selection: ' -NoNewline -ForegroundColor Green
    $prompt = Read-Host
    if ($prompt -ne 'Y' -and $prompt -ne 'Yes') {
        'User selected yes' | Trace-Output -Level Verbose
        return $false
    }
    else {
        'User selected no' | Trace-Output -Level Verbose
        return $true
    }
}