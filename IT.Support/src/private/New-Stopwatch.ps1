function New-Stopwatch {
<#
    .DESCRIPTION
    Internal function that returns a stopwatch object for use in loops
#>
    [CmdletBinding()]
    param (

    )

    try {
        $stopWatch = [System.Diagnostics.Stopwatch]::new()
        $stopWatch.Start()
        return $stopWatch
    }
    catch {
        $PSItem | Format-Exception
    }
}