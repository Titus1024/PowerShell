function Set-TraceOutputFile {
    # Caches the trace output file path
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$TraceOutputFile
    )
    $script:ITUtilities_Private.Cache.TraceOutputFile = $TraceOutputFile
}