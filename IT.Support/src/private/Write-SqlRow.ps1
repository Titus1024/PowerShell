function Write-SqlRow {
    <#
    .DESCRIPTION
    Internal function for writing logs to the database server
    .PARAMETER TraceEvent
    PSCustomObject to be written to the database
    .EXAMPLE
    Write-SqlRow -TraceEvent $traceEvent
    .EXAMPLE
    $traceEvent | Write-SqlRow
#>
    [CmdletBinding(DefaultParameterSetName = "Pipeline")]
    param (
        [Parameter(ParameterSetName = "Pipeline", Mandatory, DontShow, ValueFromPipeline)]
        [PSCustomObject]
        $Pipeline,
        [Parameter(ParameterSetName = "Parameter", Mandatory)]
        [PSCustomObject]
        $TraceEvent
    )

    try {
        if ($PSBoundParameters.Keys -contains 'Pipeline') {
            $TraceEvent = $Pipeline
        }

        $config = $script:ITUtilities_Private.LoggingDefaults.ConnectionConfig
        Write-SqlTableData @config -InputData $TraceEvent
    }
    catch {
        $PSItem | Format-Exception
    }
}