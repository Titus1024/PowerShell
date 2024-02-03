function Format-Output {
    # Simplifies making output written to the host pretty
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $Message,
        [Parameter(ValueFromPipelineByPropertyName)]
        $Object,
        [ValidateSet("Pass", "Warning", "Fail")]
        $Status
    )
    
    # Defines colors for conditional color coding
    switch ($Status) {
        'Pass' { $color = 'Green' }
        'Warning' { $color = 'Yellow' }
        'Fail' { $color = 'Red' }
        Default { $color = 'Green' }
    }

    $Message | Write-Host -NoNewline
    $Object | Write-Host -ForegroundColor $color
}